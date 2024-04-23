-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;

-- create and populate tables
create table
    if not exists ALT_SCHOOL.PRODUCTS (
        id serial primary key,
        name varchar not null,
        price numeric(10, 2) not null
    );

COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM
    '/data/products.csv' DELIMITER ',' CSV HEADER;

-- setup customers table following the example above
create table
    if not exists ALT_SCHOOL.CUSTOMERS (
        customer_id uuid primary key,
        device_id uuid NOT NULL,
        "location" varchar(255) NOT NULL,
        currency varchar(10) NULL
    );

-- copy the customers data in the /data folder into ALT_SCHOOL.CUSTOMERS
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, "location", currency)
FROM
    '/data/customers.csv' DELIMITER ',' CSV HEADER;

create table
    if not exists ALT_SCHOOL.ORDERS (
        order_id uuid not null primary key,
        customer_id uuid not null,
        "status" varchar(50) not null,
        checked_out_at timestamp not null
    );

-- copy orders data into POSTGRES
COPY ALT_SCHOOL.ORDERS (order_id, customer_id, "status", checked_out_at)
FROM
    '/data/orders.csv' DELIMITER ',' CSV HEADER;

create table
    if not exists ALT_SCHOOL.LINE_ITEMS (
        line_item_id serial primary key,
        order_id uuid NOT NULL,
        item_id int8 NOT NULL,
        quantity int8 NOT NULL
    );

-- copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES
COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM
    '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- setup the events table
create table
    if not exists ALT_SCHOOL.EVENTS (
        event_id serial primary key,
        customer_id uuid NOT NULL,
        event_data jsonb NOT NULL,
        event_timestamp timestamp NOT NULL
    );

-- copy ALT_SCHOOL.EVENTS data into POSTGRES
COPY ALT_SCHOOL.EVENTS (
    event_id,
    customer_id,
    event_data,
    event_timestamp
)
FROM
    '/data/events.csv' DELIMITER ',' CSV HEADER;