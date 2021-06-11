// Adapted from https://gorm.io/docs/#Quick-Start
package main
import (
	"fmt"
	"os"
	"strconv"
	"time"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type Product struct {
	gorm.Model
	Code  string
	Price uint
}

func main() {
	host := os.Getenv("VT_HOST")
	if(host == "") {
		println("VT_HOST must be set")
		os.Exit(1)
	}

	port := uint16(3306)
	port_str := os.Getenv("VT_PORT")
	if(port_str != "") {
		port_u64, err := strconv.ParseUint(port_str, 10, 16)
		if(err != nil) {
			fmt.Printf("Failed to parse VT_PORT ('%s'):  %s\n", port_str, err)
			os.Exit(2)
		}
		port = uint16(port_u64)
	}

	auth := os.Getenv("VT_USERNAME")
	if(auth == "") {
		println("VT_USERNAME must be set")
		os.Exit(3)
	}

	password := os.Getenv("VT_PASSWORD")
	if(password != "") {
		auth = auth + ":" + password
	}

	database := os.Getenv("VT_DATABASE")
	if(database == "") {
		println("VT_DATABASE must be set")
		os.Exit(4)
	}

	db_url := fmt.Sprintf("%s@tcp(%s:%d)/%s?parseTime=true", auth, host, port, database)
	fmt.Printf("--- Generated database URL: %s\n", db_url)
	var db *gorm.DB
	var err error
	for {
		db, err = gorm.Open(mysql.New(mysql.Config{
			DSN: db_url,
		}), &gorm.Config{})
		if(err == nil) {
			break
		}
		time.Sleep(1 * time.Second)
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

