run:
	./uart.sh

clean:
	rm *.o sim.ghw synth.vhd testbench *.cf

zip:
	zip xknotem00 uart_rx* zprava.pdf