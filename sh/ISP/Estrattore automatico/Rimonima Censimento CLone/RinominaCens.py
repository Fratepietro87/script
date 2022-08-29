#!/opt/opsware/agent/bin/python

import os

Lista = {
".A":["APPOOPER","APPAOPER"],
".B":["BPPOOPER","BPPAOPER"],
".B0":["B0POOPER","B0PAOPER"],
".C":["CPPOOPER","CPPAOPER"],
".C0":["C0POOPER","C0PAOPER"],
".DC":["DPPOOPER","DPPAOPER"],
".E":["EPPOOPER","EPPAOPER"],
".FC":["FPPOOPER","FPPAOPER"],
".H":["HPPOOPER","HPPAOPER"],
".H0":["H0POOPER","H0PAOPER"],
".I":["IPPOOPER","IPPAOPER"],
".J":["JPPOOPER","JPPAOPER"],
".K":["KPPOOPER","KPPAOPER"],
".L":["LPPOOPER","LPPAOPER"],
".M":["MPPOOPER","MPPAOPER"],
".N":["NPPOOPER","NPPAOPER"],
".O":["OPPOOPER","OPPAOPER"],
".P":["PPPOOPER","PPPAOPER"],
".QC":["QPPOOPER","QPPAOPER"],
".Q0":["Q0POOPER","Q0PAOPER"],
".R":["RPPOOPER","RPPAOPER"],
".S":["SPPOOPER","SPPAOPER"],
".T":["TPPOOPER","TPPAOPER"],
".T0":["T0POOPER","T0PAOPER"],
".U":["UPPOOPER","UPPAOPER"],
".V":["VPPOOPER","VPPAOPER"],
".X":["XPEDMERV","XPEDMERV"],
".YC":["YPPOOPER","YPPAOPER"],
".ZC":["ZPPOOPER","ZPPAOPER"],
".XM":["XPMOSVIL","XPMOSVIL"],
".X0":["X0PEMERV","X0PEMERV"]
}


for filename in os.listdir("."):
       if filename.endswith(".py"):
          continue
       MessaLettera = 0
          for Chiave in Lista:
              if filename.endswith(Chiave):
                  MessaLettera = 1
                  break

              if MessaLettera == 1:
                  continue

              for Chiave in Lista:
                  if Lista[Chiave][0] in open(filename).read():
                      os.rename(filename, filename+Chiave)
                      break
                  if Lista[Chiave][1] in open(filename).read():
                      os.rename(filename, filename+Chiave)
                      break


