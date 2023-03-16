Description
The website that we will be implemeting has a landing page similar to the one of virustotal. It offers the possibility to upload a file or a post link. The input will then be checked from a security perspective and a result will be presented (whether the website or file is malicious or not). Alternatively, the database can be queried if it contains information regarding a file or a URL.

The website is comprised of 3 major components:

1.The frontend which is essentially the user facing interface, the actual website. When a specific action is taken (for example, a button is pressed), the frontend intercepts the action and sends a request to the middleware.
2.The middleware receives raw requests from the frontend and transforms them into calls to functions that are implemented in the backend.
3.The backend does the actual heavy lifting in terms of implementing the logic: it stores information in a database and computes whatever values are requested.
Each of the above components will have to be implemented for each of the 3 milestones of the projects. Essentially, each component represents an assignment.

    Milestone 1 - Implementing the backend
The backend implements a database where all of the information is stored. We want to track down information about users, files and URLs. As a consequence, we will be using a database where we will define 3 collections:

1.The users collection which stores the following fields:
    an email address - a string that represents the unique identifier of user
    a username - a string that represents the actual name that is publicly posted for a user
    a password - a string that represents the encrypted password for a user
    a name - an optional string field that represents the real name of the user
    a description - an optional string field that represents the description of the user (hobbies, passions etc.)
2.The files collection which stores the following fields:
    a file id - a number that represents the unique identifier for an entry in this collection
    a user id - a string that contains the email address of the user that added this file
    the file contents - a ubyte[] that stores the bytes of the file
    a hash of the file - a string that contains the result of applying a hash function to the file contents
    threat level - a number representing the degree of maliciousness of the file
3.The URLs collection which stores the following fields:
    a URL id - a string that represents the unique identifier for an entry in this collection
    a user id - a string that contains the email address of the user that added this URL
    an address - a string that contains the actual URL (e.g. “www.google.com”)
    a security level - a number representing the degree ofm maliciousness of the URL
    a list of aliases - a string[] that contains different aliases for this website
The database is implemented using mongo-db. On top of mongo-db we will be using the vibe-d framework, which is a a high-performance asynchronous I/O, concurrency and web application toolkit written in D. By using vibe-d we will be able to both implement the database and create the server (for milestone 2).
    
    Milestone 2 - Implementing the web API
Now that our database is up and runnnig, we need to create the code that connects the user facing interface with the backend. This means that we need to have a server running that accepts requests from the user interface, it forwards them to the backend and then delivers back a response. Most of the time, the middleware extracts the user input and creates the appropriate query that is passed to the backend. However, there are situations where some actions need to be taken on the middleware side.

    TODO: Milestone 3