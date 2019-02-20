PROJECT = test
BUILD_DIR = build

# список сырцов
SOURCES += main.cpp
SOURCES += foo1/foo1.cpp
SOURCES += foo3.cpp

INCLUDES += -Ifoo1
INCLUDES += -Ifoo4


# второй список сырцов, который компилируется с другими правилами относительно основных
# например, сишный компилятор
OTHER_SOURCES += foo4/foo4.cpp
OTHER_SOURCES += foo4/foo2/foo2.cpp

OTHER_INCLUDES += -Ifoo4/foo2


# из списка сырцов делаем список объектов(цели)
OBJECTS += $(addprefix $(BUILD_DIR)/inner/,$(notdir $(SOURCES:.cpp=.o)))
# чтобы работало %.o: %.cpp в целях
vpath %.cpp $(sort $(dir $(SOURCES))) 

# из второго списка сырцов делаем список объектов(цели)
# , чтобы make видел разницу, их собираем в другую папку
OTHER_OBJECTS += $(addprefix $(BUILD_DIR)/inner2/,$(notdir $(OTHER_SOURCES:.cpp=.o)))
vpath %.cpp $(sort $(dir $(OTHER_SOURCES)))

all: $(BUILD_DIR)/$(PROJECT)

$(BUILD_DIR)/$(PROJECT) : $(OBJECTS) $(OTHER_OBJECTS)
	g++ $(OBJECTS) $(OTHER_OBJECTS) -flto -o $(BUILD_DIR)/$(PROJECT)

$(BUILD_DIR)/inner/%.o: %.cpp Makefile | $(BUILD_DIR) 
	g++ -c $(INCLUDES) -Wa,-a,-ad,-alms=$(BUILD_DIR)/inner/$(notdir $(<:.cpp=.lst)) $< -o $@

$(BUILD_DIR)/inner2/%.o: %.cpp Makefile | $(BUILD_DIR)
	gcc -c $(OTHER_INCLUDES) -Wa,-a,-ad,-alms=$(BUILD_DIR)/inner2/$(notdir $(<:.cpp=.lst)) $< -o $@

$(BUILD_DIR):
	mkdir $@
	mkdir $@/inner
	mkdir $@/inner2

clean:
	-rm -fR .dep $(BUILD_DIR)


# печатает списки и переменные, использование: make print-SOURCES
print-%  : ; @echo $* = $($*)