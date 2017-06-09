USE MASTER
GO

IF DB_ID('KARPINSKY8') IS NOT NULL
DROP DATABASE KARPINSKY8
GO

CREATE DATABASE KARPINSKY8
ON PRIMARY 
(NAME = KARPINSKY8, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\KARPINSKY8.mdf',
SIZE = 30MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10MB)
LOG ON
(NAME = KARPINSKY8_log, FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\DATA\KARPINSKY8.ldf',
SIZE = 30MB, MAXSIZE = UNLIMITED, FILEGROWTH = 10MB)
GO

USE KARPINSKY8
GO

CREATE TABLE Genres(
	id bigint NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	genre nvarchar(255) NOT NULL
);

CREATE TABLE Books(
	id bigint NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	title nvarchar(255) NOT NULL,
	genre_id bigint NOT NULL FOREIGN KEY REFERENCES Genres(id),
	publish_date date NOT NULL,
	inflows int NOT NULL,
	ISBN varchar(17) NOT NULL,
	cover varchar(50) NOT NULL,
	publisher varchar(255) NOT NULL,
	rtf_text text NOT NULL,
	available bit NOT NULL
);

ALTER TABLE Books
	ADD CONSTRAINT UK_ISBN UNIQUE(ISBN)

ALTER TABLE Books
	ADD CONSTRAINT CHK_Book CHECK(YEAR(publish_date) > 1950 AND inflows > 0)

CREATE TABLE Authors(
	id bigint NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	full_name nvarchar(255) NOT NULL,
);

CREATE TABLE BooksAuthors(
	book_id bigint NOT NULL FOREIGN KEY REFERENCES Books(id),
	author_id bigint NOT NULL FOREIGN KEY REFERENCES Authors(id),
	CONSTRAINT PK_Book_Author PRIMARY KEY(book_id, author_id)
);

CREATE TABLE Readers(
	id bigint NOT NULL IDENTITY(1, 1) PRIMARY KEY,
	full_name nvarchar(255) NOT NULL,
	phone_number varchar(30) NOT NULL,
	adress varchar(255) NOT NULL,
	birth_date date NOT NULL
);

CREATE TABLE BooksReaders(
	book_id bigint NOT NULL FOREIGN KEY REFERENCES Books(id),
	reader_id bigint NOT NULL FOREIGN KEY REFERENCES Readers(id),
	out_date date NOT NULL,
	return_date date NOT NULL
	CONSTRAINT PK_Book_Reader PRIMARY KEY(book_id, reader_id)
);

INSERT INTO Genres
	VALUES
		('Sci-Fi'), 
		('Fantasy'),
		('Classic'),
		('Mystery'),
		('Detective'),
		('Fun'),
		('Psychology'),
		('Education'),
		('Romance')

INSERT INTO Books
	VALUES
		('Harry Potter and the Half-Blood Prince', 2, '2005-07-16', 3, '0-7475-8108-8', 'harry.png', 'Bloomsbury', 'Harry was a naughty boy', 1),
		('Enders Game', 1, '1985-01-15', 5, '0-312-93208-1', 'ender.png', 'Tor Books', 'What have I done? How could you not tell me that this was real and not just a simulation', 1),
		('Fifty Shades of Grey', 9, '2011-06-20', 7, '978-1-61213-028-6', 'shades.png', 'Vintage Books', 'And he said to her: SUM FUK?', 0)

INSERT INTO Authors
	VALUES
		('J. K. Rowling'),
		('E. L. James'),
		('Orson Scott Card')

INSERT INTO BooksAuthors
	VALUES
		(1, 1),
		(2, 3),
		(3, 2)

INSERT INTO Readers
	VALUES
		('John The Third', '000-000-010-11', 'Columbia, Superman st. 13', '1459-03-22'),
		('Olaf The Viking', '123-456-789-32', 'Denmark', '0900-06-12')

INSERT INTO BooksReaders
	VALUES
		(3, 2, '2004-03-26', '2012-02-29'),
		(2, 1, '1603-11-05', '2070-09-15')

SELECT * FROM Genres;
SELECT * FROM Books;
SELECT * FROM Authors;
SELECT * FROM BooksAuthors;
SELECT * FROM Readers;
SELECT * FROM BooksReaders;
