from __future__ import print_function
from pyrad.client import Client
from pyrad.dictionary import Dictionary
import pyrad.packet

srv = Client(server="localhost", secret=b"testing123",
             dict=Dictionary("dictionary"))

# create request
req = srv.CreateAuthPacket(code=pyrad.packet.AccessRequest,
                           User_Name="bob", NAS_Identifier="ThatNAS")
req["User-Password"] = req.PwCrypt("test")

# send request
reply = srv.SendPacket(req)

if reply.code == pyrad.packet.AccessAccept:
    print("access accepted")
else:
    print("access denied")

print("Attributes returned by server:")
for i in reply.keys():
    print("%s: %s" % (i, reply[i]))
