import std.algorithm.searching;
import std.conv;
import std.digest;
import std.digest.sha;
import std.range;
import std.stdio;
import std.string;
import std.typecons;

import vibe.db.mongo.mongo : connectMongoDB, MongoClient, MongoCollection;
import vibe.data.bson;

import dauth : makeHash, toPassword, parseHash;

struct DBConnection
{
    enum UserRet
    {
        OK,
        ERR_NULL_PASS,
        ERR_USER_EXISTS,
        ERR_INVALID_EMAIL,
        ERR_WRONG_USER,
        ERR_WRONG_PASS,
        NOT_IMPLEMENTED
    }

    MongoClient client ;
    MongoCollection users;
    MongoCollection files;
    MongoCollection urls;
    
    this(string dbUser, string dbPassword, string dbAddr, string dbPort, string dbName)
    {
        client = connectMongoDB("mongodb://" ~ dbUser ~ ":" ~ dbPassword ~ "@" ~ dbAddr ~ ":" ~ dbPort ~ "/");
        users = client.getCollection(dbName ~ ".users");
        files= client.getCollection(dbName ~ ".files");
        urls= client.getCollection(dbName ~ ".urls");
    }

    UserRet addUser(string email, string username, string password, string name = "", string desc = "")
    {
        if(password==null)
            return UserRet.ERR_NULL_PASS;
        if(email.indexOf('@')==-1)
            return UserRet.ERR_INVALID_EMAIL;
        if(users.findOne(["user":username])!=Bson(null))
            return UserRet.ERR_USER_EXISTS;
        users.insert(["email": email, "user":username, "pass": password]);
        return UserRet.OK;
    }

    UserRet authUser(string email, string password)
    {
        if(password==null)
            return UserRet.ERR_NULL_PASS;
        if(email.indexOf('@')==-1)
            return UserRet.ERR_INVALID_EMAIL;
        if(users.findOne(["email":email])!=Bson(null)&&users.findOne(["pass":password])==Bson(null))
            return UserRet.ERR_WRONG_PASS;
        return UserRet.OK;
    }

    UserRet deleteUser(string email)
    {
        users.remove(["email":email]);
        return UserRet.OK;
    }

    struct File
    {
        @name("_id") BsonObjectID id; // represented as _id in the db
        string userId;
        ubyte[] binData;
        string fileName;
        string digest;
        string securityLevel;
    }

    enum FileRet
    {
        OK,
        FILE_EXISTS,
        ERR_EMPTY_FILE,
        NOT_IMPLEMENTED
    }

    FileRet addFile(string userId, immutable ubyte[] binData, string fileName)
    {
        if(binData==null)
            return FileRet.ERR_EMPTY_FILE;
        auto rez=files.findOne(["binData":digest!SHA512(binData).toHexString().to!string]);
        if(rez!=Bson(null))
            return FileRet.FILE_EXISTS;
        files.insert(["usersID":userId, "binData":digest!SHA512(binData).toHexString().to!string, "fileName":fileName]);
        return FileRet.OK;
    }

    File[] getFiles(string userId)
    {
        auto rez=files.find(["usersID" : userId]);
        File[] file;
        if(!rez.empty){
            foreach (i; rez)
            {
                file[file.length++].digest = cast(string)(i["binData"]);
            }
        }
        return file;
    }

    Nullable!File getFile(string digest)
    in(!digest.empty)
    do
    {
        Nullable!File file;
        File fil;
        auto result=files.findOne(["binData":digest]);
        if(!result.isNull){
            fil.digest=cast(string)result["binData"];
            file=Nullable!File(fil);
        }
        return file;
    }

    void deleteFile(string digest)
    in(!digest.empty)
    do
    {
        files.remove(["binData":digest]);
    }

    struct Url
    {
        @name("_id") BsonObjectID id; // represented as _id in the db
        string userId;
        string addr;
        string securityLevel;
        string[] aliases;
    }

    enum UrlRet
    {
        OK,
        URL_EXISTS,
        ERR_EMPTY_URL,
        NOT_IMPLEMENTED
    }

    UrlRet addUrl(string userId, string urlAddress)
    {
        if(urlAddress==null){
            return UrlRet.ERR_EMPTY_URL;
        }
        if(urls.findOne(["urlAddress": urlAddress])!=Bson(null))
            return UrlRet.URL_EXISTS;
        urls.insert(["userId":userId,"urlAddress": urlAddress]);
        return UrlRet.OK;
    }

    Url[] getUrls(string userId)
    {
        Url[] url;
        auto rez=urls.find(["userId":userId]);
        if(!rez.empty){
            foreach (i; rez)
            {
                url.length++;
                url[url.length-1].addr=cast(string)(i["urlAddress"]);
            }
        }
        return url;
    }

    Nullable!Url getUrl(string urlAddress)
    in(!urlAddress.empty)
    do
    {
        Nullable!Url url;
        Url ur;
        auto result=urls.findOne(["urlAddress":urlAddress]);
        if(!result.isNull){
            ur.addr=cast(string)(result["urlAddress"]);
            url=Nullable!Url(ur);
        }
        return url;
    }

    void deleteUrl(string urlAddress)
    in(!urlAddress.empty)
    do
    {
        urls.remove(["urlAddress": urlAddress]);
    }
}
