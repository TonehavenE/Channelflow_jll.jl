# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule Channelflow_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("Channelflow")
JLLWrappers.@generate_main_file("Channelflow", UUID("3f71b17c-0b5c-5f71-8ab7-7b799a58f30d"))
end  # module Channelflow_jll
