## Project Progress Database Setup (PoC)
Ethan Assefa

We will be setting up a locally hosted database using `sqlite` and `Python` as a Proof-of-Concept (PoC) to determine whether the planned project is feasible to implement. 

The database will hold the following information in the form of relational tables:
- Users and their related information (username, email, password, position, etc.)
- Collaborators and their related information (name, description, funder status, etc.)
- Projects and related information (name, start/end date, status, etc.)
- Deliverables and their related information (name, description, status, etc.)
- Tasks and their related information (name, status, priority, assignment, etc.)
- Updates and their related information (description, etc.)
- Audit logs (user, action, etc.)

### E-R Diagram
Below is the Entity-Relation Diagram (ERD) of the database as we have conceptualized it:
- Lines between tables represent the foreign keys that link the tables to one another

This is simply a starting point, we can add or remove tables and/or variables as needed. This should be discussed and finalized before the true implementation of the project.

![](https://drive.google.com/file/d/1GrEhF7ES8mGUljo9fqnP-tkHko3McRaH/view?usp=sharing)
