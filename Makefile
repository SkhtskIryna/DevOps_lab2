CXX = g++
CXXFLAGS = -Wall -g
SOURCES = main.cpp suite.cpp
HEADERS = suite.h
EXECUTABLE = program

all: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES) $(HEADERS)
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -f $(EXECUTABLE) *.o
