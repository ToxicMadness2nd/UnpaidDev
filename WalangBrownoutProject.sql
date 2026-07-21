-- ============================================
-- WalangBrownout Appliances - Database Schema
-- Sprint 1: Analysis & Architecture Blueprint
-- CCS112 Case Study
-- ============================================

CREATE DATABASE IF NOT EXISTS WalangBrownout;
USE WalangBrownout;

-- ============================================
-- 1. Users
-- Login/auth, roles for alert routing
-- ============================================
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('Purchasing_Manager', 'Warehouse_Staff', 'Operations_Manager', 'Admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. Suppliers
-- Vendors WalangBrownout restocks from
-- ============================================
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    contact_number VARCHAR(20),
    email VARCHAR(100),
    lead_time_days INT NOT NULL DEFAULT 7
);

-- ============================================
-- 3. Products
-- Master catalog
-- ============================================
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    supplier_id INT,
    abc_class ENUM('A', 'B', 'C') NOT NULL DEFAULT 'C',
    is_seasonal BOOLEAN NOT NULL DEFAULT FALSE,
    unit_cost DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- ============================================


-- ============================================
-- 5. Orders
-- Customer-facing sales header
-- ============================================
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_contact VARCHAR(100),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING', 'FULFILLED', 'UNFULFILLED', 'CANCELLED') NOT NULL DEFAULT 'PENDING'
);

-- ============================================
-- 6. Details
-- Line items per ord
-- ============================================
-- 7. Transactions
-- Append-only stock movement ledger
-- ============================================
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    transaction_type ENUM('RECEIVE', 'SALE', 'RESERVE', 'ADJUSTMENT', 'WRITE_OFF') NOT NULL,
    quantity_change INT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_id INT NULL,
    performed_by_user_id INT NOT NULL,
    FOREIGN KEY (batch_id) REFERENCES Batches(batch_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (performed_by_user_id) REFERENCES Users(user_id)
);

-- ============================================
-- 8. Purchase_Orders
-- WalangBrownout restocking from a supplier

-- ============================================
-- 9. Notifications
-- Logs each alert tier firing
-- ============================================
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    alert_tier ENUM('Yellow', 'Orange', 'Red', 'Expiry') NOT NULL,
    related_product_id INT,
    related_batch_id INT NULL,
    recipient_user_id INT NOT NULL,
    triggered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('UNREAD', 'ACKNOWLEDGED', 'RESOLVED') NOT NULL DEFAULT 'UNREAD',
    resolved_at DATETIME NULL,
    FOREIGN KEY (related_product_id) REFERENCES Products(product_id),
    FOREIGN KEY (related_batch_id) REFERENCES Batches(batch_id),
    FOREIGN KEY (recipient_user_id) REFERENCES Users(user_id)
);