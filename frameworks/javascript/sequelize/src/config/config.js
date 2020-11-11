var db = {
	"dialect": "mysql",
	"host": process.env.VT_HOST,
	"port": process.env.VT_PORT,
	"username": process.env.VT_USERNAME,
	"password": process.env.VT_PASSWORD,
	"database": process.env.VT_DATABASE
};

module.exports = {
	"development": db,
	"test": db,
	"production": db
};

