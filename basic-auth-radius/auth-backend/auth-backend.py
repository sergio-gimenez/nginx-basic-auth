import os

from fastapi import FastAPI, HTTPException

app = FastAPI()

RADIUS_SECRET = os.environ.get("RADIUS_SECRET")
RADIUS_SERVER = os.environ.get("RADIUS_SERVER")

if not RADIUS_SECRET or not RADIUS_SERVER:
    raise Exception("RADIUS_SECRET and RADIUS_SERVER must be set")


@app.post("/auth")
async def authenticate(user: str, password: str):
    from pyrad.client import Client
    from pyrad.dictionary import Dictionary
    import pyrad.packet

    srv = Client(server=RADIUS_SERVER, secret=RADIUS_SECRET.encode(),
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
