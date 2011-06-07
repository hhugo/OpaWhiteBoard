OPA=opa

all: opawhiteboard.exe

opawhiteboard.exe:
	$(OPA) src/buffer.opa src/client.opa src/builder.opa src/main.opa -o opawhiteboard.exe

clean:
	rm -Rf *.exe _build _tracks *.log
