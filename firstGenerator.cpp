//
// Created by hrttsh-mac on 2018/10/15.
//

#include "Halide.h"
using namespace Halide;

class MyFirstGeneroatr : public Halide::Generator<MyFirstGeneroatr>  {
public:
    Input<uint8_t> offset{"offset"};
    Input<Buffer<uint8_t>> input{"input", 2};

    Output<Buffer <uint8_t >> brighter{"brighter", 2};

    Var x, y;

    void generate() {
        brighter(x, y) = input(x, y) + offset;
        brighter.vectorize(x, 16).parallel(y);
    }

};

HALIDE_REGISTER_GENERATOR(MyFirstGeneroatr, my_first_generator);

class MySencondGenerator : public Halide::Generator<MySencondGenerator> {
public:
    GeneratorParam<bool> parallel{"parallel", true};

    GeneratorParam<float> scale{"scale",1.0f,0.0f,100.0f};

    enum class Rotation {None, Clockwise, CounterClockwise};
    GeneratorParam <Rotation > rotation {"rotation",
        Rotation::None,
        {{"none", Rotation ::None},
         {"cw", Rotation::Clockwise},
         { "ccw", Rotation::CounterClockwise}}};

    Input<uint8_t> offset{"offset"};
    Input<Buffer<uint8_t>> input{"input", 2};

    Output<Buffer<>> output{"output", 2};

    Var x, y;

    void generate() {
        Func brighter;
        brighter(x, y) = scale * (input(x, y) + offset);

        Func rotated;
        switch ((Rotation) rotation) {
            case Rotation::None:
                rotated(x, y) = brighter(x, y);
                break;
            case Rotation::Clockwise:
                rotated(x, y) = brighter(y, 100 - x);
                break;
            case Rotation::CounterClockwise:
                rotated(x, y) = brighter(100 - y, x);
                break;
        }

        output(x,y) = cast(output.type(), rotated(x,y));
        output.vectorize(x, natural_vector_size(output.type()));

        if(parallel) {
            output.parallel(y);
        }

        if(rotation != Rotation::None) {
            rotated.compute_at(output, y).vectorize(x, natural_vector_size(rotated.output_types()[0]));
        }

    };
};

HALIDE_REGISTER_GENERATOR(MySencondGenerator, my_second_generator);