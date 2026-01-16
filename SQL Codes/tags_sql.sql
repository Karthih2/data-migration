CREATE TABLE moviesdb.movie_tags (
    userId INT,
    movieId INT,
    tag VARCHAR(255),
    tag_time DATETIME
);

LOAD DATA LOCAL INFILE 'D:/Data Migration/Dataset/tags.csv'
INTO TABLE moviesdb.movie_tags
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(userId, movieId, tag, @ts)
SET tag_time = FROM_UNIXTIME(@ts);


select * from moviesdb.movie_tags;