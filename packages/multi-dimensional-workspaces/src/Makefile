TARGET = libmulti-dimensional-workspaces.so
CXXFLAGS = -Wall -Werror -O2 -std=c++23 -g `pkg-config --cflags pixman-1 libdrm hyprland pangocairo libinput libudev wayland-server xkbcommon`
LDFLAGS = -shared

default: $(TARGET)

OBJECTS = $(patsubst %.c, %.o, $(wildcard *.c)) $(patsubst %.cpp, %.o, $(wildcard *.cpp))
HEADERS = $(wildcard *.h) $(wildcard *.hpp)

%.o: %.c $(HEADERS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(OBJECTS)

install: $(TARGET)
	install -d $(out)/lib/
	install -m 755 $(TARGET) $(out)/lib/
