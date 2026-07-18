<img src="https://img.shields.io/badge/MySQL%20to%20MongoDB-ETL%20%26%20Denormalization%20Migration-4DB33D?style=for-the-badge&logo=mongodb" width="100%">
<h1 align="center">🔄 Relational to NoSQL Migration</h1>
<p align="center"><b>ETL • Denormalization • Query-Driven Design</b></p>
<p align="center">
  <img src="https://img.shields.io/badge/Python-3.10+-blue?logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/MySQL-Relational-blue?logo=mysql&logoColor=white">
  <img src="https://img.shields.io/badge/MongoDB-Document--Oriented-green?logo=mongodb&logoColor=white">
  <img src="https://img.shields.io/badge/ETL-Data%20Migration-orange">
  <img src="https://img.shields.io/badge/Data%20Modeling-Schema%20Design-critical">
  <img src="https://img.shields.io/badge/Project-Complete-success">
</p>
<p align="center">A complete migration workflow demonstrating how a normalized relational movie database (MySQL) is transformed into a denormalized document database (MongoDB) — covering data modeling, ETL, and performance optimization on a MovieLens-style dataset.</p>

---

## 📋 Project Overview

**Key Features:**
- **Complete ETL Pipeline** — extract from MySQL, transform to document model, load into MongoDB
- **Data Denormalization** — embedded documents and arrays for optimized query performance
- **Schema Design** — document structure balancing read/write patterns
- **Index Optimization** — strategic indexing for common query patterns
- **Data Validation** — migration verification with count comparisons and integrity checks

---

## 🗄️ Database Schemas

### MySQL Schema (Source) — 4 normalized tables

| Table | Columns |
|---|---|
| `movies` | `movieId` (PK), `title`, `genres` |
| `links` | `movieId` (FK), `imdbId`, `tmdbId` |
| `ratings` | `userId`, `movieId` (FK), `rating`, `rating_time` |
| `movie_tags` | `userId`, `movieId` (FK), `tag`, `tag_time` |

### MongoDB Schema (Target) — 3 collections with embedded documents

**`movies`**
```json
{
  "_id": ObjectId,
  "movieId": 1,
  "title": "Toy Story",
  "genres": ["Adventure", "Animation", "Children", "Comedy", "Fantasy"],
  "release_year": "1995",
  "links": { "imdbId": "0114709", "tmdbId": 862 },
  "averageRating": 3.92,
  "ratingCount": 215,
  "tags": [
    {"tag": "fun", "tagCount": 1},
    {"tag": "pixar", "tagCount": 3}
  ]
}
```

**`ratings`**
```json
{
  "_id": ObjectId,
  "userId": 1,
  "movieId": 1,
  "rating": 4.0,
  "rating_time": ISODate("2000-07-31T00:15:03Z")
}
```

**`users`**
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

---

## 🔄 Migration Process

### 1️⃣ Data Extraction
Connect to MySQL and pull from all four tables:
```python
conn = pymysql.connect(host=host, user=user, password=password, database=database)
movies_df = pd.read_sql("SELECT m.*, l.imdbId, l.tmdbId FROM movies m LEFT JOIN links l ON m.movieId = l.movieId", conn)
```

### 2️⃣ Data Transformation
**Movie documents:**
- Extract release year from title via regex
- Split pipe-delimited genres into arrays
- Embed link info as nested objects
- Calculate and embed rating statistics
- Aggregate and embed tag information

**User documents:**
- Aggregate all ratings and tags per user
- Calculate stats (total ratings, average rating, total tags)
- Maintain recent activity (top 10 ratings and tags by timestamp)

### 3️⃣ Data Loading
```python
db.movies.insert_many(movies_df.to_dict('records'))
db.ratings.insert_many(ratings_df.to_dict('records'))
db.users.insert_many(users_list)
```

### 4️⃣ Index Creation
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

---

## 📊 Migration Results

| Entity | MySQL Count | MongoDB Count | Status |
|---|---|---|---|
| Movies | 9,742 | 9,742 | ✅ Complete |
| Ratings | 100,836 | 100,836 | ✅ Complete |
| Users | 610 | 610 | ✅ Complete |

---

## 🛠️ Technologies Used

<p align="left">
  <img src="https://img.shields.io/badge/Python%203.x-Core%20Language-3776AB?style=flat-square&logo=python&logoColor=white">
  <img src="https://img.shields.io/badge/PyMySQL-MySQL%20Connector-4479A1?style=flat-square&logo=mysql&logoColor=white">
  <img src="https://img.shields.io/badge/PyMongo-MongoDB%20Driver-47A248?style=flat-square&logo=mongodb&logoColor=white">
  <img src="https://img.shields.io/badge/Pandas-Data%20Transformation-150458?style=flat-square&logo=pandas&logoColor=white">
  <img src="https://img.shields.io/badge/Matplotlib-Visualization-11557C?style=flat-square&logo=plotly&logoColor=white">
  <img src="https://img.shields.io/badge/python--dotenv-Env%20Config-ECD53F?style=flat-square&logo=python&logoColor=black">
</p>

---

## 📁 Project Structure

```
├── migration_script.ipynb              # Main migration script
├── .env                                # Environment variables (not tracked)
├── requirements.txt                    # Python dependencies
│
├── data_models/                        # Database schemas & datasets
│   ├── MongoDB_MoviesDB_DataModel      # MongoDB data model
│   └── MySql_MovieDB_DataModel         # MySQL data model
│ 
├── datasets/
|    ├── README.txt                     # Dataset references
│    ├── movies.csv
│    ├── ratings.csv
│    ├── tags.csv
│    └── links.csv
├── SQL Codes/                          # SQL Codes
│    ├── links_sql.sql
│    ├── movies_sql.sql
│    └── tags_sql.sql
│
├── visualizations/                     # Migration result charts
│   ├── movies_migration.png
│   ├── ratings_migration.png
│   └── users_migration.png
│
└── README.md                           # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites
- Python 3.7+
- MySQL Server
- MongoDB Server
- Access credentials for both databases

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/mysql-mongodb-migration.git
cd mysql-mongodb-migration
```

**2. Install dependencies**
```bash
pip install -r requirements.txt
```

**3. Configure environment variables** in `.env`
```env
# MySQL Configuration
host=localhost
user=your_mysql_user
password=your_mysql_password
database=moviesdb

# MongoDB Configuration
MONGO_URI=mongodb://localhost:27017/
```

**4. Run the migration**
```bash
python migration_script.py
```

---

## 📈 Key Learnings

### Database Design Decisions
1. **Embedding vs. Referencing** — link info and tags embedded in `movies` for read optimization; ratings kept separate due to high volume and update frequency
2. **Denormalization Trade-offs** — pre-calculated aggregates (`averageRating`, `ratingCount`) reduce query complexity at the cost of update complexity
3. **Index Strategy** — compound index on `(userId, rating_time)` supports user activity queries; text index on `title` enables search
4. **Array Fields** — genres stored as arrays enable multi-value queries via MongoDB's array operators

### Performance Considerations
- **Read Optimization** — embedded documents eliminate JOINs for common queries
- **Write Trade-offs** — updates to ratings require updating movie aggregates
- **Index Overhead** — strategic indexing balances query performance with storage cost
- **Document Size** — kept under MongoDB's 16MB limit via recent-activity limits

---

## 🔍 Sample Queries

**Find all Action movies with high ratings:**
```javascript
db.movies.find({
  genres: "Action",
  averageRating: { $gte: 4.0 }
})
```

**Get a user's recent activity:**
```javascript
db.users.findOne(
  { userId: 1 },
  { recentRatings: 1, recentTags: 1 }
)
```

**Text search for movies:**
```javascript
db.movies.find({
  $text: { $search: "toy story" }
})
```

---

## 📝 Future Enhancements

- [ ] Implement incremental migration for ongoing data sync
- [ ] Add data validation and error handling
- [ ] Create MongoDB aggregation pipeline examples
- [ ] Implement rollback mechanism
- [ ] Add unit tests for transformation logic
- [ ] Performance benchmarking between MySQL and MongoDB queries

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!

## 👤 Author
**Karthick S**

## 🙏 Acknowledgments
- MovieLens dataset for sample data structure
- MongoDB documentation for best practices

---

<div align="center">

✨ <i>This project demonstrates practical experience with database migration, ETL processes, and both relational and document-oriented database paradigms.</i> ✨

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=120&section=footer&animation=twinkling" width="100%"/>

</div>
