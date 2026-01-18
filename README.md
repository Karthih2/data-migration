# Relational to NoSQL Migration: ETL, Denormalization, and Query-Driven Design

![Python](https://img.shields.io/badge/Python-3.10+-blue?logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Relational-blue?logo=mysql&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Document--Oriented-green?logo=mongodb&logoColor=white)
![ETL](https://img.shields.io/badge/ETL-Data%20Migration-orange)
![Data Modeling](https://img.shields.io/badge/Data%20Modeling-Schema%20Design-critical)
![Status](https://img.shields.io/badge/Project-Complete-success)

A comprehensive data migration project demonstrating the transformation of a relational movie database from MySQL to MongoDB's document-oriented structure, including data modeling, ETL processes, and performance optimization.

## 📋 Project Overview

This project showcases a complete migration workflow from a normalized relational database (MySQL) to a denormalized NoSQL database (MongoDB). The migration transforms a MovieLens-style dataset while demonstrating key concepts in both database paradigms.

### Key Features

- **Complete ETL Pipeline**: Extract data from MySQL, transform to document model, load into MongoDB
- **Data Denormalization**: Embedded documents and arrays for optimized query performance
- **Schema Design**: Thoughtful document structure balancing read/write patterns
- **Index Optimization**: Strategic indexing for common query patterns
- **Data Validation**: Migration verification with count comparisons and data integrity checks

## 🗄️ Database Schemas

### MySQL Schema (Source)

The relational database consists of four normalized tables:

**movies**
- `movieId` (INT, PK)
- `title` (VARCHAR)
- `genres` (VARCHAR)

**links**
- `movieId` (INT, FK)
- `imdbId` (VARCHAR)
- `tmdbId` (INT)

**ratings**
- `userId` (INT)
- `movieId` (INT, FK)
- `rating` (DOUBLE)
- `rating_time` (DATETIME)

**movie_tags**
- `userId` (INT)
- `movieId` (INT, FK)
- `tag` (VARCHAR)
- `tag_time` (DATETIME)

### MongoDB Schema (Target)

The document-oriented database uses three collections with embedded documents:

**movies**
```json
{
  "_id": ObjectId,
  "movieId": 1,
  "title": "Toy Story",
  "genres": ["Adventure", "Animation", "Children", "Comedy", "Fantasy"],
  "release_year": "1995",
  "links": {
    "imdbId": "0114709",
    "tmdbId": 862
  },
  "averageRating": 3.92,
  "ratingCount": 215,
  "tags": [
    {"tag": "fun", "tagCount": 1},
    {"tag": "pixar", "tagCount": 3}
  ]
}
```

**ratings**
```json
{
  "_id": ObjectId,
  "userId": 1,
  "movieId": 1,
  "rating": 4.0,
  "rating_time": ISODate("2000-07-31T00:15:03Z")
}
```

**users**
```json
{
  "_id": ObjectId,
  "userId": 1,
  "stats": {
    "totalRatings": 232,
    "averageRating": 4.23,
    "totalTags": 13
  },
  "recentRatings": [
    {"movieId": 150, "rating": 5.0, "rating_time": ISODate}
  ],
  "recentTags": [
    {"movieId": 260, "tag": "classic", "timestamp": ISODate}
  ]
}
```

## 🔄 Migration Process

### 1. Data Extraction

Connect to MySQL and extract data from all four tables:
```python
conn = pymysql.connect(host=host, user=user, password=password, database=database)
movies_df = pd.read_sql("SELECT m.*, l.imdbId, l.tmdbId FROM movies m LEFT JOIN links l ON m.movieId = l.movieId", conn)
```

### 2. Data Transformation

**Movie Documents**
- Extract release year from title using regex
- Split pipe-delimited genres into arrays
- Embed link information as nested objects
- Calculate and embed rating statistics
- Aggregate and embed tag information

**User Documents**
- Aggregate all ratings and tags per user
- Calculate user statistics (total ratings, average rating, total tags)
- Maintain recent activity (top 10 ratings and tags by timestamp)

### 3. Data Loading

Bulk insert transformed documents into MongoDB:
```python
db.movies.insert_many(movies_df.to_dict('records'))
db.ratings.insert_many(ratings_df.to_dict('records'))
db.users.insert_many(users_list)
```

### 4. Index Creation

Strategic indexes for query optimization:
```python
# Movies collection
db.movies.create_index('movieId', unique=True)
db.movies.create_index('genres')
db.movies.create_index([('title', 'text')])

# Ratings collection
db.ratings.create_index([('userId', 1), ('rating_time', -1)])
db.ratings.create_index('movieId')

# Users collection
db.users.create_index('userId', unique=True)
```

## 📊 Migration Results

| Entity | MySQL Count | MongoDB Count | Status |
|--------|-------------|---------------|--------|
| Movies | 9,742 | 9,742 | ✅ Complete |
| Ratings | 100,836 | 100,836 | ✅ Complete |
| Users | 610 | 610 | ✅ Complete |

## 🛠️ Technologies Used

- **Python 3.x**: Core programming language
- **PyMySQL**: MySQL database connector
- **PyMongo**: MongoDB driver for Python
- **Pandas**: Data manipulation and transformation
- **Matplotlib**: Data visualization
- **python-dotenv**: Environment variable management

## 📁 Project Structure

```
├── migration_script.ipynb              # Main migration script
├── .env                              # Environment variables (not tracked)
├── requirements.txt                  # Python dependencies
│
├── data_models/                      # Database schemas & datasets
│   ├── MongoDB_MoviesDB_DataModel   # MongoDB data model
|   ├── MySql_MovieDB_DataModel      # MySQL data model
│   │
│   ├── datasets/                     # Dataset references
│   │   ├── movies.csv                # Movies dataset
│   │   ├── ratings.csv               # Ratings dataset
│   │   ├── tags.csv                  # Tags dataset
│   │   └── links.csv                 # Links dataset
│
├── visualizations/                   # Migration result charts
│   ├── movies_migration.png
│   ├── ratings_migration.png
│   └── users_migration.png
│
└── README.md                          # Project documentation
```

## 🚀 Getting Started

### Prerequisites

- Python 3.7+
- MySQL Server
- MongoDB Server
- Access credentials for both databases

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mysql-mongodb-migration.git
cd mysql-mongodb-migration
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure environment variables in `.env`:
```env
# MySQL Configuration
host=localhost
user=your_mysql_user
password=your_mysql_password
database=moviesdb

# MongoDB Configuration
MONGO_URI=mongodb://localhost:27017/
```

4. Run the migration:
```bash
python migration_script.py
```

## 📈 Key Learnings

### Database Design Decisions

1. **Embedding vs. Referencing**: Embedded link information and tags in movies collection for read optimization, while keeping ratings separate due to high volume and update frequency.

2. **Denormalization Trade-offs**: Pre-calculated aggregates (averageRating, ratingCount) reduce query complexity at the cost of update complexity.

3. **Index Strategy**: Compound indexes on (userId, rating_time) support user activity queries, while text index on title enables search functionality.

4. **Array Fields**: Genres stored as arrays enable multi-value queries using MongoDB's array operators.

### Performance Considerations

- **Read Optimization**: Embedded documents eliminate JOIN operations for common queries
- **Write Trade-offs**: Updates to ratings require updating movie aggregates
- **Index Overhead**: Strategic indexing balances query performance with storage cost
- **Document Size**: Maintained under MongoDB's 16MB limit through recent activity limits

## 🔍 Sample Queries

### MongoDB Queries

Find all Action movies with high ratings:
```javascript
db.movies.find({
  genres: "Action",
  averageRating: { $gte: 4.0 }
})
```

Get user's recent activity:
```javascript
db.users.findOne(
  { userId: 1 },
  { recentRatings: 1, recentTags: 1 }
)
```

Text search for movies:
```javascript
db.movies.find({
  $text: { $search: "toy story" }
})
```

## 📝 Future Enhancements

- [ ] Implement incremental migration for ongoing data sync
- [ ] Add data validation and error handling
- [ ] Create MongoDB aggregation pipeline examples
- [ ] Implement rollback mechanism
- [ ] Add unit tests for transformation logic
- [ ] Performance benchmarking between MySQL and MongoDB queries

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Karthick S**

## 🙏 Acknowledgments

- MovieLens dataset for sample data structure
- MongoDB documentation for best practices

---

*This project demonstrates practical experience with database migration, ETL processes, and understanding of both relational and document-oriented database paradigms.*
