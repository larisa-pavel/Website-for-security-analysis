Security Check Website
Description
This project is for a website that provides a security check for files or URLs. The website is comprised of three major components:

Frontend: The user-facing interface.
Middleware: Receives requests from the frontend and transforms them into calls to functions that are implemented in the backend.
Backend: Does the actual heavy lifting in terms of implementing the logic.
Each of the above components will have to be implemented for each of the three milestones of the project.

Milestone 1 - Implementing the Backend
The backend implements a database where all of the information is stored. We want to track down information about users, files, and URLs. As a consequence, we will be using a database where we will define 3 collections:

The users collection which stores the following fields:

An email address - a string that represents the unique identifier of user.
A username - a string that represents the actual name that is publicly posted for a user.
A password - a string that represents the encrypted password for a user.
A name - an optional string field that represents the real name of the user.
A description - an optional string field that represents the description of the user (hobbies, passions, etc.).
The files collection which stores the following fields:

A file id - a number that represents the unique identifier for an entry in this collection.
A user id - a string that contains the email address of the user that added this file.
The file contents - a ubyte[] that stores the bytes of the file.
A hash of the file - a string that contains the result of applying a hash function to the file contents.
Threat level - a number representing the degree of maliciousness of the file.
The URLs collection which stores the following fields:

A URL id - a string that represents the unique identifier for an entry in this collection.
A user id - a string that contains the email address of the user that added this URL.
An address - a string that contains the actual URL (e.g. “www.google.com”).
Security level - a number representing the degree of maliciousness of the URL.
A list of aliases - a string[] that contains different aliases for this website.
The database is implemented using mongo-db. On top of mongo-db, we will be using the vibe-d framework, which is a high-performance asynchronous I/O, concurrency and web application toolkit written in D. By using vibe-d, we will be able to both implement the database and create the server (for milestone 2).

Milestone 2 - Implementing the Web API
Now that our database is up and running, we need to create the code that connects the user-facing interface with the backend. This means that we need to have a server running that accepts requests from the user interface, forwards them to the backend, and then delivers back a response. Most of the time, the middleware extracts the user input and creates the appropriate query that is passed to the backend. However, there are situations where some actions need to be taken on the middleware side.

Milestone 3 - Not Described

Milestone 3 is not described.

Installation
To install the project, follow these steps:

Install mongo-db and vibe-d framework.
Clone the repository: git clone https://github.com/username/repository-name.git
Change directory into the project directory: cd repository-name
Run the server: command to start the server
Usage
