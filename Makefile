CXX = g++
CXXFLAGS = -g -O2

SRCS = tests/main_test.cpp src/suite.cpp
OBJS = $(SRCS:.cpp=.o)

TARGET = tests/main_test
PROGRAM = program

all: $(PROGRAM) $(TARGET)

$(PROGRAM): main.o suite.o
	$(CXX) $(CXXFLAGS) -o $@ $^

$(TARGET): tests/main_test.o suite.o
	$(CXX) $(CXXFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET) $(PROGRAM)

.PHONY: all clean
