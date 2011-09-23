CAIROOPA=-I ../cairo-opa
INCLUDE=-I +cairo  $(CAIROOPA)
LINK=--mllopt cairo.cmxa
OPB=opa-plugin-builder
OPA=opa $(OPAOPT)

V2=hh.cairo.opx src/v2/client.opa src/v2/buffer.opa src/v2/main.opa

all: OWB-v2.exe

OWB-v2.exe:
	$(OPA) $(INCLUDE) $(LINK) $(V2) -o OWB-v2.exe

clean:
	rm -Rf *.exe _build _tracks *.log *.opp
