CREATE DATABASE IF NOT EXISTS delivery;
USE delivery;

CREATE TABLE  IF NOT EXISTS profile (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(256),
    second_name VARCHAR(256),
    phone VARCHAR(16),
    email VARCHAR(256),
    gender VARCHAR(2),
    birthday TIMESTAMP,
    is_push_allow TINYINT(1),
    is_superuser TINYINT(1),
    is_staff TINYINT(1)
);

CREATE TABLE  IF NOT EXISTS category (
    id INTEGER PRIMARY KEY,
    is_active boolean,
    title VARCHAR(255) NOT NULL,
    updated TIMESTAMP NOT NULL,
    created TIMESTAMP NOT NULL,
    slug VARCHAR(500) UNIQUE,
    image VARCHAR(128) UNIQUE,
    description TEXT,
    parent_id INTEGER
);

ALTER TABLE category
ADD FOREIGN KEY (parent_id) REFERENCES category(id);

CREATE TABLE  IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(256),
    is_active TINYINT(1),
    updated TIMESTAMP,
    created TIMESTAMP,
    slug VARCHAR(1024),
    description TEXT,
    image VARCHAR(128),
    category_id INT,
    stock INT,
    FOREIGN KEY (category_id) REFERENCES category(id)
);

CREATE TABLE  IF NOT EXISTS address (
	id INT AUTO_INCREMENT PRIMARY KEY,
	profile_id INT,
	dist VARCHAR(256),
	street VARCHAR(256),
	house VARCHAR(32),
	liter INT,
	entrance INT,
	is_doorphone_exist TINYINT(1),
	not_call_doorphone TINYINT(1),
	latitude DECIMAL(10, 2),
	longitude DECIMAL(10, 2),
	geolocation JSON,
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE TABLE contract (
    id INT AUTO_INCREMENT PRIMARY KEY,
    extra_code VARCHAR(256),
    addtext TEXT,
    total DECIMAL(10, 2),
    updated TIMESTAMP,
    created TIMESTAMP,
    payment_done TINYINT(1),
    payment_date TIMESTAMP,
    phone VARCHAR(16),
    email VARCHAR(128),
    address_id INT,
    profile_id INT,
    bonuses_used INT,
    bonuses_apply TINYINT(1),
    FOREIGN KEY (address_id) REFERENCES address(id),
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);

CREATE TABLE  IF NOT EXISTS metrics (
	id INT AUTO_INCREMENT PRIMARY KEY,
	table_name VARCHAR(256),
	operation_type VARCHAR(256),
	operation_date TIMESTAMP,
	execution_time DECIMAL(10,2),
	rows_affected INT
);

CREATE TABLE  IF NOT EXISTS logs (
	id INT AUTO_INCREMENT PRIMARY KEY,
	log_level VARCHAR(16),
	log_message TEXT,
	log_date TIMESTAMP,
	profile_id INT,
	operation_type VARCHAR(256),
	operation_table VARCHAR(256),
    FOREIGN KEY (profile_id) REFERENCES profile(id)
);
