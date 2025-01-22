-- Table: Users
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL CHECK (role IN ('Admin', 'User')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Automatically set timestamp
);

-- Table: Projects
CREATE TABLE Projects (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key
    project_name TEXT NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT NOT NULL CHECK (status IN ('Not Started', 'In Progress', 'Completed', 'On Hold')),
    created_by INTEGER NOT NULL, -- Foreign key reference
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Table: Tasks
CREATE TABLE Tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key
    project_id INTEGER NOT NULL, -- Foreign key reference
    task_name TEXT NOT NULL,
    assigned_to INTEGER NOT NULL, -- Foreign key reference
    status TEXT NOT NULL CHECK (status IN ('Not Started', 'In Progress', 'Completed')),
    priority TEXT NOT NULL CHECK (priority IN ('Low', 'Medium', 'High')),
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: Updates
CREATE TABLE Updates (
    update_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key
    project_id INTEGER NOT NULL, -- Foreign key reference
    update_text TEXT NOT NULL,
    created_by INTEGER NOT NULL, -- Foreign key reference
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES Users(user_id) ON DELETE SET NULL
);

-- Table: AuditLogs
CREATE TABLE AuditLogs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key
    user_id INTEGER NOT NULL, -- Foreign key reference
    action TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);
