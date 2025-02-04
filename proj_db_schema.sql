-- Create the Users table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role ENUM('Admin', 'Lead', 'User') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the Projects table
CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status ENUM('Not Started', 'In Progress', 'Completed', 'On Hold') NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES Users(user_id) 
        ON UPDATE CASCADE --  If user deleted, reassigned to admin
);

-- Create the Collaborators table
CREATE TABLE Collaborators (
    collaborator_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_funder BOOLEAN NOT NULL DEFAULT FALSE, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the Project_Collaborators junction table for Many-to-Many relationship
CREATE TABLE Project_Collaborators (
    project_id INT NOT NULL,
    collaborator_id INT NOT NULL,
    PRIMARY KEY (project_id, collaborator_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (collaborator_id) REFERENCES Collaborators(collaborator_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the Tasks table
CREATE TABLE Tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    assigned_to INT,
    status ENUM('Not Started', 'In Progress', 'Completed') NOT NULL,
    priority ENUM('Low', 'Medium', 'High') NOT NULL DEFAULT 'Medium',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) 
        ON DELETE CASCADE ON UPDATE CASCADE, -- If project deleted, linked data also deleted
    FOREIGN KEY (assigned_to) REFERENCES Users(user_id) 
        ON DELETE SET NULL ON UPDATE CASCADE, --  If user deleted, it remains
    FOREIGN KEY (created_by) REFERENCES Users(user_id) 
        ON UPDATE CASCADE --  If user deleted, reassigned to admin
);

-- Create the Deliverables table
CREATE TABLE Deliverables (
    deliverable_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('Not Started', 'In Progress', 'Completed', 'On Hold') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) 
        ON DELETE CASCADE ON UPDATE CASCADE, -- If project deleted, linked data also deleted
    FOREIGN KEY (created_by) REFERENCES Users(user_id) 
        ON UPDATE CASCADE --  If user deleted, reassigned to admin
);

-- Create the Task_Deliverables junction table for Many-to-Many relationship
CREATE TABLE Task_Deliverables (
    task_id INT NOT NULL,
    deliverable_id INT NOT NULL,
    PRIMARY KEY (task_id, deliverable_id),
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    FOREIGN KEY (deliverable_id) REFERENCES Deliverables(deliverable_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the Updates table
CREATE TABLE Updates (
    update_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    update_text TEXT NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id) 
        ON DELETE CASCADE ON UPDATE CASCADE, -- If project deleted, linked data also deleted
    FOREIGN KEY (created_by) REFERENCES Users(user_id) 
        ON UPDATE CASCADE --  If user deleted, reassigned to admin
);

-- Create the AuditLogs table
CREATE TABLE AuditLogs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) 
        ON DELETE SET NULL ON UPDATE CASCADE --  If user deleted, it remains
);

-- Trigger to reassign project, deliverable, task, update to admin if created user is deleted
DELIMITER //

CREATE TRIGGER before_user_delete
BEFORE DELETE ON Users
FOR EACH ROW
BEGIN
    DECLARE fallback_admin INT;

    -- Find an Admin user to take over ownership
    SELECT user_id INTO fallback_admin FROM Users WHERE role = 'Admin' LIMIT 1;

    -- If no Admin exists, prevent deletion
    IF fallback_admin IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete user: No admin available for reassignment.';
    ELSE
        -- Reassign created_by fields to the fallback admin
        UPDATE Projects SET created_by = fallback_admin WHERE created_by = OLD.user_id;
        UPDATE Tasks SET created_by = fallback_admin WHERE created_by = OLD.user_id;
        UPDATE Deliverables SET created_by = fallback_admin WHERE created_by = OLD.user_id;
        UPDATE Updates SET created_by = fallback_admin WHERE created_by = OLD.user_id;
    END IF;
END //

DELIMITER ;