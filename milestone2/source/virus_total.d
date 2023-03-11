import std.conv;
import std.digest;
import std.digest.sha;
import std.stdio;

import vibe.d;
import vibe.web.auth;

import db_conn;

static struct AuthInfo
{
@safe:
    string userEmail;
    string AccessToken;
}

@path("api/v1")
@requiresAuth
interface VirusTotalAPIRoot
{
    // Users management
    @noAuth
    @method(HTTPMethod.POST)
    @path("signup")
    Json addUser(string userEmail, string username, string password, string name = "", string desc = "");

    @noAuth
    @method(HTTPMethod.POST)
    @path("login")
    Json authUser(string userEmail, string password);

    @anyAuth
    @method(HTTPMethod.POST)
    @path("delete_user")
    Json deleteUser(string userEmail);

    // URLs management
    @anyAuth
    @method(HTTPMethod.POST)
    @path("add_url") // the path could also be "/url/add", thus defining the url "namespace" in the URL
    Json addUrl(string userEmail, string urlAddress);

    @noAuth
    @method(HTTPMethod.GET)
    @path("url_info")
    Json getUrlInfo(string urlAddress);

    @noAuth
    @method(HTTPMethod.GET)
    @path ("user_urls")
    Json getUserUrls(string userEmail);

    @anyAuth
    @method(HTTPMethod.POST)
    @path("delete_url")
    Json deleteUrl(string userEmail, string urlAddress);

    // Files management
    @anyAuth
    @method(HTTPMethod.POST)
    @path("add_file")
    Json addFile(string userEmail, immutable ubyte[] binData, string fileName);

    @noAuth
    @method(HTTPMethod.GET)
    @path("file_info")
    Json getFileInfo(string fileSHA512Digest);

    @noAuth
    @method(HTTPMethod.GET)
    @path("user_files")
    Json getUserFiles(string userEmail);

    @anyAuth
    @method(HTTPMethod.POST)
    @path("delete_file")
    Json deleteFile(string userEmail, string fileSHA512Digest);
}

class VirusTotalAPI : VirusTotalAPIRoot
{
    this(DBConnection dbClient)
    {
        this.dbClient = dbClient;
    }

    @noRoute AuthInfo authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        // If "userEmail" is not present, an error 500 (ISE) will be returned
        string userEmail = req.json["userEmail"].get!string;
        string userAccessToken = dbClient.getUserAccessToken(userEmail);
        // Use headers.get to check if key exists
        string headerAccessToken = req.headers.get("AccessToken");
        if (headerAccessToken && headerAccessToken == userAccessToken)
            return AuthInfo(userEmail);
        throw new HTTPStatusException(HTTPStatus.unauthorized);
    }

override:

    Json addUser(string userEmail, string username, string password, string name = "", string desc = "")
    {
        dbClient.UserRet rez=dbClient.addUser(userEmail,username,password,name,desc);
        if(dbClient.UserRet.ERR_INVALID_EMAIL==rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        if(dbClient.UserRet.ERR_NULL_PASS==rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        if(dbClient.UserRet.ERR_USER_EXISTS==rez){
            throw new HTTPStatusException(HTTPStatus.unauthorized, "[Unauthorized] user action not defined");
        }
        return serializeToJson(rez);
    }

    Json authUser(string userEmail, string password)
    {
        dbClient.UserRet rez=dbClient.authUser(userEmail,password);
        if(dbClient.UserRet.ERR_NULL_PASS==rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        if(dbClient.UserRet.ERR_INVALID_EMAIL==rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        if(dbClient.UserRet.ERR_WRONG_PASS==rez){
            throw new HTTPStatusException(HTTPStatus.unauthorized, "[Unauthorized] user action not defined");
        }
        if(dbClient.UserRet.ERR_WRONG_USER==rez){
            throw new HTTPStatusException(HTTPStatus.unauthorized, "[Unauthorized] user action not defined");
        }
        string acces= dbClient.generateUserAccessToken(userEmail);
        AuthInfo fin;
        fin.AccessToken=acces;
        return serializeToJson(fin);
    }

    Json deleteUser(string userEmail)
    {

        dbClient.UserRet rez=dbClient.deleteUser(userEmail);
        if(dbClient.UserRet.ERR_INVALID_EMAIL == rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        return serializeToJson(rez);
    }

    // URLs management

    Json addUrl(string userEmail, string urlAddress)
    {
        dbClient.UrlRet rez=dbClient.addUrl(userEmail,urlAddress);
        if(dbClient.UrlRet.ERR_EMPTY_URL==rez){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        return serializeToJson(rez);
    }

    Json deleteUrl(string userEmail, string urlAddress)
    {
        if(urlAddress.empty){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        Json nimic;
        dbClient.deleteUrl(userEmail,urlAddress);
        return nimic;
    }

    Json getUrlInfo(string urlAddress)
    {
        auto rez=dbClient.getUrl(urlAddress);
        if(rez.isNull){
            throw new HTTPStatusException(HTTPStatus.notFound, "[Not Found] user action not defined");
        }
        return serializeToJson(rez);
    }

    Json getUserUrls(string userEmail)
    {
        return serializeToJson(dbClient.getUrls(userEmail));
    }

    // Files management

    Json addFile(string userEmail, immutable ubyte[] binData, string fileName)
    {
        if(binData.empty){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Bad Request] user action not defined");
        }
        dbClient.FileRet rez=dbClient.addFile(userEmail,binData,fileName);
        return serializeToJson(rez);
    }

    Json getFileInfo(string fileSHA512Digest)
    {
        auto rez=dbClient.getFile(fileSHA512Digest);
        if(rez.isNull){
            throw new HTTPStatusException(HTTPStatus.notFound, "[Not Found] user action not defined");
        }
        return serializeToJson(rez);
    }

    Json getUserFiles(string userEmail)
    {
        return serializeToJson(dbClient.getFiles(userEmail));
    }

    Json deleteFile(string userEmail, string fileSHA512Digest)
    {
        if(fileSHA512Digest.empty){
            throw new HTTPStatusException(HTTPStatus.badRequest, "[Internal Server Error] user action not defined");
        }
        Json nimic;
        dbClient.deleteFile(userEmail,fileSHA512Digest);
        return nimic;
    }

private:
    DBConnection dbClient;
}
