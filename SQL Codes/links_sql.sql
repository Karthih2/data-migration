CREATE TABLE moviesdb.links (
  movieId INT,
  imdbId VARCHAR(15),
  tmdbId INT
);

LOAD DATA LOCAL INFILE 'D:/Data Migration/Dataset/links.csv'
INTO TABLE moviesdb.links
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  movieId,
  imdbId,
  @tmdbId
)
SET
  tmdbId = NULLIF(TRIM(@tmdbId), '');




