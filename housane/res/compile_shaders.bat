@echo off

for /R %%f in (*.vert) do (
    %VULKAN_SDK%\Bin\glslc.exe %%~nf.vert -o %%~nf_vertex.sprv
)

for /R %%f in (*.frag) do (
    %VULKAN_SDK%\Bin\glslc.exe %%~nf.frag -o %%~nf_frag.sprv
)

for /R %%f in (*.comp) do (
    %VULKAN_SDK%\Bin\glslc.exe %%~nf.comp -o %%~nf_comp.sprv
)