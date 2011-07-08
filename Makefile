INCLUDE=-I +cairo
LINK=--mllopt cairo.cmxa
OPB=opa-plugin-builder
OPA=opa $(OPAOPT)

all: opawhiteboard.exe

cairo.opp: src/opacairo/cairo.ml
	$(OPB) $(INCLUDE) src/opacairo/cairo.ml -o cairo

opawhiteboard.exe.old:
	$(OPA) src/buffer.opa src/client.opa src/builder.opa src/main.opa -o opawhiteboard.exe

opawhiteboard.exe: cairo.opp
	$(OPA) $(INCLUDE) $(LINK) cairo.opp src/opacairo/buffer.opa src/opacairo/client.opa src/opacairo/main.opa -o opawhiteboard.exe

clean:
	rm -Rf *.exe _build _tracks *.log *.opp
