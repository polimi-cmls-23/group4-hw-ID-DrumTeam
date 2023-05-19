SerialPort.listDevices

~port = SerialPort.new("COM3", 9600);
b = NetAddr.new("127.0.0.1", 5112);
~port.close;
(
~charArray = [ ];
~getValues = Routine.new({
var ascii;
{
ascii = ~port.read.asAscii;
if(ascii.isDecDigit,{~charArray = ~charArray.add(ascii)});
if(ascii == $a,{
~val1= ~charArray.collect(_.digit).convertDigits;
~charArray = [ ];
b.sendMsg("/juce/cutoffFrequencySlider", ~val1);
});
}.loop;
}).play;
)