// Adapted from https://gorm.io/docs/#Quick-Start
package main
import (
	"fmt"
	"net/url"
	"os"
	"strconv"
	"strings"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type Product struct {
	gorm.Model
	Code  string
	Price uint
}

func main() {
	db_url := os.Getenv("DATABASE_URL")
	if(db_url == "") {
		println("DATABASE_URL must be set")
		os.Exit(1)
	}

	parsed, err := url.Parse(db_url)
	if(err != nil) {
		fmt.Printf("Failed to parse DATABASE_URL: %s\n", err)
		os.Exit(2)
	}

	if(parsed.User == nil) {
		println("Must include username/password in DATABASE_URL")
		os.Exit(3)
	}

	host_parts := strings.Split(parsed.Host, ":")
	var host string
	var port uint16
	if(len(host_parts) > 2) {
		fmt.Printf("Malformed host:port in DATABASE_URL: '%s'\n", parsed.Host)
		os.Exit(4)
	} else if(len(host_parts) == 2) {
		host = host_parts[0]
		port_u64, err := strconv.ParseUint(host_parts[1], 10, 16)
		if(err != nil) {
			fmt.Printf("Malformed host:port in DATABASE_URL: '%s'\n", parsed.Host)
			os.Exit(5)
		}
		port = uint16(port_u64)
	} else if(len(host_parts) == 1) {
		host = host_parts[0]
		port = 3306
	}

	if(parsed.Path == "" || parsed.Path == "/") {
		println("Must include a database in DATABASE_URL")
		os.Exit(6)
	}

	auth := parsed.User.Username()
	password, has_password := parsed.User.Password()
	if(has_password) {
		auth = auth + ":" + password
	}

	db_url = fmt.Sprintf("%s@tcp(%s:%d)%s?parseTime=true", auth, host, port, parsed.Path)
	fmt.Printf("--- Generated database URL: %s\n", db_url)
	db, err := gorm.Open(mysql.New(mysql.Config{
		DSN: db_url,
	}), &gorm.Config{})
	if(err != nil) {
		fmt.Printf("Error connecting to database: %s\n", err)
		os.Exit(7)
	}

	err = db.AutoMigrate(&Product{})
	if(err != nil) {
		fmt.Printf("AutoMigrate() failed: %s\n", err)
		os.Exit(8)
	}

	tx := db.Create(&Product{Code: "D42", Price: 100})
	if(tx.Error != nil) {
		fmt.Printf("Create() failed: %s\n", err)
		os.Exit(9)
	}

	var product Product

	tx = db.First(&product, 1) // Find product with integer primary key
	if(tx.Error != nil) {
		fmt.Printf("First() by id failed: %s\n", tx.Error)
		os.Exit(10)
	}
	if(product.Code != "D42" || product.Price != 100) {
		println("First() by id result doesn't match expected values")
		os.Exit(11)
	}

	tx = db.First(&product, "code = ?", "D42")
	if(tx.Error != nil) {
		fmt.Printf("First by code failed: %s\n", tx.Error)
		os.Exit(12)
	}
	if(product.Code != "D42" || product.Price != 100) {
		println("First() by code result doesn't match expected values")
		os.Exit(13)
	}

	tx = db.Model(&product).Update("Price", 200) // Update single field
	if(tx.Error != nil) {
		fmt.Printf("Update 1 failed: %s\n", tx.Error)
		os.Exit(14)
	}
	db.First(&product, 1)
	if(product.Code != "D42" || product.Price != 200) {
		println("Result after update 1 doesn't match expected values")
		os.Exit(15)
	}

	tx = db.Model(&product).Updates(Product{Price: 300, Code: "E42"}) // Multi update with struct
	if(tx.Error != nil) {
		fmt.Printf("Update 2 failed: %s\n", tx.Error)
		os.Exit(16)
	}
	db.First(&product, 1)
	if(product.Code != "E42" || product.Price != 300) {
		println("Result after update 2 doesn't match expected values")
		os.Exit(17)
	}

	tx = db.Model(&product).Updates(map[string]interface{}{"Price": 400, "Code": "F42"}) // Multi update with map
	if(tx.Error != nil) {
		fmt.Printf("Update 3 failed: %s\n", tx.Error)
		os.Exit(18)
	}
	db.First(&product, 1)
	if(product.Code != "F42" || product.Price != 400) {
		println("Result after update 3 doesn't match expected values")
		os.Exit(19)
	}

	tx = db.Delete(&product, 1)
	if(tx.Error != nil) {
		fmt.Printf("Delete failed: %s\n", tx.Error)
		os.Exit(20)
	}
	println("--- Should show 'record not found' error:")
	tx = db.First(&product, 1)
	if(tx.Error == nil) {
		println("Result after delete was not an error")
		os.Exit(21)
	} else if(tx.Error != gorm.ErrRecordNotFound) {
		fmt.Printf("Result after delete was not a 'record not found' error: %s\n", tx.Error)
		os.Exit(21)
	}
}

