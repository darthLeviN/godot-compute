#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 400, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
    float data[];
}
my_data_buffer;

// The code we want to execute in each invocation
void main() {
    // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
    my_data_buffer.data[gl_GlobalInvocationID.x] = my_data_buffer.data[gl_GlobalInvocationID.x]*1.5 + 1.1;
    my_data_buffer.data[gl_GlobalInvocationID.x] = pow(my_data_buffer.data[gl_GlobalInvocationID.x], 1.001);
    my_data_buffer.data[gl_GlobalInvocationID.x] = my_data_buffer.data[gl_GlobalInvocationID.x]/1.0001;
}
