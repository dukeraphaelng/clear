CREATE USER root WITH PASSWORD 'postgres';
CREATE DATABASE root;

CREATE USER test WITH PASSWORD 'test' CREATEDB;
CREATE DATABASE clear_secondary_spec
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

CREATE TABLE models_post_stats (id serial PRIMARY KEY, post_id INTEGER);