CREATE TABLE moviesdb.movies (
  movieId INT,
  title VARCHAR(255),
  genres VARCHAR(255)
);

LOAD DATA LOCAL INFILE 'D:/Data Migration/Dataset/movies.csv'
INTO TABLE moviesdb.movies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(movieId, title, genres);
