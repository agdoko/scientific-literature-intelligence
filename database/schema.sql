-- Scientific Literature Intelligence System Database Schema
-- Designed for: Technical Interview Portfolio (Palantir, ElevenLabs, Anthropic, OpenAI)
-- Focus: Battery research literature with complex relationship modeling

-- =============================================================================
-- CORE ENTITIES: The foundation of our knowledge graph
-- =============================================================================

-- AUTHORS: Central entity for tracking researcher networks
-- Interview Concept: Demonstrates understanding of identity resolution
CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    affiliation TEXT,
    orcid TEXT UNIQUE, -- Industry standard researcher ID
    h_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PAPERS: Core scientific literature entity
-- Interview Concept: Shows temporal modeling and metadata management
CREATE TABLE papers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    abstract TEXT,
    doi TEXT UNIQUE, -- Digital Object Identifier - industry standard
    arxiv_id TEXT UNIQUE, -- For preprints
    publication_date DATE,
    journal TEXT,
    volume TEXT,
    issue TEXT,
    pages TEXT,
    paper_type TEXT CHECK (paper_type IN ('journal', 'conference', 'preprint', 'thesis')),
    
    -- Full-text search capability (SQLite FTS5)
    -- Interview Concept: Demonstrates search optimization knowledge
    full_text TEXT, -- Will be indexed with FTS5
    
    -- Research domain classification
    primary_domain TEXT DEFAULT 'battery_research',
    secondary_domains TEXT, -- JSON array of additional domains
    
    -- Metrics for impact analysis
    citation_count INTEGER DEFAULT 0,
    download_count INTEGER DEFAULT 0,
    
    -- Temporal tracking
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- DATASETS: Linking papers to their underlying data
-- Interview Concept: Shows data provenance tracking (critical at AI companies)
CREATE TABLE datasets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    url TEXT,
    github_repo TEXT,
    data_type TEXT, -- 'experimental', 'simulation', 'survey', etc.
    size_mb INTEGER,
    format TEXT, -- 'csv', 'hdf5', 'parquet', etc.
    license TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- RELATIONSHIP TABLES: The real complexity lies here
-- =============================================================================

-- PAPER_AUTHORS: Many-to-many with author ordering
-- Interview Concept: Demonstrates handling of ordered relationships
CREATE TABLE paper_authors (
    paper_id INTEGER,
    author_id INTEGER,
    author_position INTEGER NOT NULL, -- 1st author, 2nd author, etc.
    contribution_type TEXT, -- 'primary', 'corresponding', 'equal', etc.
    PRIMARY KEY (paper_id, author_id),
    FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE CASCADE
);

-- CITATIONS: The citation graph - this is where graph analytics happen
-- Interview Concept: Shows understanding of network/graph data in relational DBs
CREATE TABLE citations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    citing_paper_id INTEGER NOT NULL,
    cited_paper_id INTEGER NOT NULL,
    citation_context TEXT, -- The sentence/paragraph where citation appears
    citation_type TEXT CHECK (citation_type IN ('direct', 'comparative', 'methodological', 'background')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Prevent self-citation and duplicate citations
    UNIQUE(citing_paper_id, cited_paper_id),
    CHECK(citing_paper_id != cited_paper_id),
    
    FOREIGN KEY (citing_paper_id) REFERENCES papers(id) ON DELETE CASCADE,
    FOREIGN KEY (cited_paper_id) REFERENCES papers(id) ON DELETE CASCADE
);

-- PAPER_DATASETS: Which papers use which datasets
-- Interview Concept: Data lineage tracking (essential for ML companies)
CREATE TABLE paper_datasets (
    paper_id INTEGER,
    dataset_id INTEGER,
    usage_type TEXT, -- 'primary', 'validation', 'comparison', 'replication'
    PRIMARY KEY (paper_id, dataset_id),
    FOREIGN KEY (paper_id) REFERENCES papers(id) ON DELETE CASCADE,
    FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON DELETE CASCADE
);

-- =============================================================================
-- ADVANCED FEATURES: What sets this apart from basic CRUD
-- =============================================================================

-- RESEARCH_TRENDS: Time-series analysis of research topics
-- Interview Concept: Temporal analytics and trend detection
CREATE TABLE research_trends (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    keyword TEXT NOT NULL,
    year INTEGER NOT NULL,
    paper_count INTEGER DEFAULT 0,
    citation_impact REAL DEFAULT 0.0, -- Average citations for papers with this keyword
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(keyword, year)
);

-- COLLABORATION_NETWORKS: Precomputed author collaboration metrics
-- Interview Concept: Graph metrics and network analysis
CREATE TABLE collaboration_networks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author1_id INTEGER,
    author2_id INTEGER,
    collaboration_count INTEGER DEFAULT 1,
    first_collaboration_date DATE,
    last_collaboration_date DATE,
    shared_papers TEXT, -- JSON array of paper IDs
    
    -- Ensure consistent ordering for undirected relationships
    CHECK(author1_id < author2_id),
    UNIQUE(author1_id, author2_id),
    
    FOREIGN KEY (author1_id) REFERENCES authors(id) ON DELETE CASCADE,
    FOREIGN KEY (author2_id) REFERENCES authors(id) ON DELETE CASCADE
);

-- =============================================================================
-- INDEXES: Performance optimization (crucial for interview discussions)
-- =============================================================================

-- Primary lookup indexes
CREATE INDEX idx_papers_doi ON papers(doi);
CREATE INDEX idx_papers_publication_date ON papers(publication_date);
CREATE INDEX idx_papers_journal ON papers(journal);
CREATE INDEX idx_authors_name ON authors(name);
CREATE INDEX idx_authors_affiliation ON authors(affiliation);

-- Relationship traversal indexes
CREATE INDEX idx_paper_authors_paper ON paper_authors(paper_id);
CREATE INDEX idx_paper_authors_author ON paper_authors(author_id);
CREATE INDEX idx_citations_citing ON citations(citing_paper_id);
CREATE INDEX idx_citations_cited ON citations(cited_paper_id);

-- Analytics indexes
CREATE INDEX idx_papers_citation_count ON papers(citation_count DESC);
CREATE INDEX idx_research_trends_year_keyword ON research_trends(year, keyword);

-- Composite indexes for common query patterns
CREATE INDEX idx_papers_domain_date ON papers(primary_domain, publication_date);
CREATE INDEX idx_citations_type_date ON citations(citation_type, created_at);

-- =============================================================================
-- FULL-TEXT SEARCH: Essential for literature systems
-- =============================================================================

-- FTS5 virtual table for paper content search
-- Interview Concept: Shows understanding of search optimization
CREATE VIRTUAL TABLE papers_fts USING fts5(
    title,
    abstract,
    full_text,
    content='papers',
    content_rowid='id'
);

-- Triggers to keep FTS table in sync
CREATE TRIGGER papers_fts_insert AFTER INSERT ON papers BEGIN
    INSERT INTO papers_fts(rowid, title, abstract, full_text)
    VALUES (new.id, new.title, new.abstract, new.full_text);
END;

CREATE TRIGGER papers_fts_delete AFTER DELETE ON papers BEGIN
    DELETE FROM papers_fts WHERE rowid = old.id;
END;

CREATE TRIGGER papers_fts_update AFTER UPDATE ON papers BEGIN
    DELETE FROM papers_fts WHERE rowid = old.id;
    INSERT INTO papers_fts(rowid, title, abstract, full_text)
    VALUES (new.id, new.title, new.abstract, new.full_text);
END;

-- =============================================================================
-- VIEWS: Simplify complex queries (shows SQL expertise)
-- =============================================================================

-- Materialized view concept: Author impact metrics
CREATE VIEW author_impact_metrics AS
SELECT 
    a.id,
    a.name,
    a.affiliation,
    COUNT(DISTINCT pa.paper_id) as paper_count,
    SUM(p.citation_count) as total_citations,
    AVG(p.citation_count) as avg_citations_per_paper,
    MAX(p.publication_date) as latest_publication,
    MIN(p.publication_date) as first_publication
FROM authors a
LEFT JOIN paper_authors pa ON a.id = pa.author_id
LEFT JOIN papers p ON pa.paper_id = p.id
GROUP BY a.id, a.name, a.affiliation;

-- Citation network view for graph analysis
CREATE VIEW citation_network AS
SELECT 
    c.citing_paper_id,
    c.cited_paper_id,
    p1.title as citing_title,
    p2.title as cited_title,
    p1.publication_date as citing_date,
    p2.publication_date as cited_date,
    c.citation_type,
    julianday(p1.publication_date) - julianday(p2.publication_date) as citation_lag_days
FROM citations c
JOIN papers p1 ON c.citing_paper_id = p1.id
JOIN papers p2 ON c.cited_paper_id = p2.id;