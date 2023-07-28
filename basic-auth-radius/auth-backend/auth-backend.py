from fastapi import FastAPI, HTTPException

app = FastAPI()


@app.post("/auth")
async def authenticate(user: str, password: str):
    from pyrad.client import Client
    from pyrad.dictionary import Dictionary
    import pyrad.packet

    srv = Client(server="localhost", secret=b"testing123",
                 dict=Dictionary("dictionary"))

    # create request
    req = srv.CreateAuthPacket(code=pyrad.packet.AccessRequest,
                               User_Name=user, NAS_Identifier="ThatNAS")
    req["User-Password"] = req.PwCrypt(password)

    # send request
    reply = srv.SendPacket(req)

    if reply.code == pyrad.packet.AccessAccept:
        return {"message": "access accepted", "attributes": reply.keys()}
    else:
        raise HTTPException(status_code=401, detail="access denied")
