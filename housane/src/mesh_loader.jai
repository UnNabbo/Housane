Mesh_Buffer :: struct{
	address: Buffer_Device_Address;
	vertex:  Allocated_Buffer;
	index:   Allocated_Buffer;
}

Mesh :: struct {
	#as buffer: Mesh_Buffer;
	
	vertices: *Vertex;
	vertices_count: u64;
	
	indices: *u32;
	indices_count: u64;
}

get_gltf_attribute_data :: (data: *cgltf_primitive, name: string)-> *void, u64, u64{
	attribute: *cgltf_attribute;
	for k : 0..data.attributes_count - 1 {
		i_attribute := *data.attributes[k];
		if to_string(i_attribute.name) == name then attribute = i_attribute;
	}
	if attribute {
		if attribute.data && attribute.data.buffer_view && attribute.data.buffer_view.buffer {
			buffer   := attribute.data.buffer_view.buffer.data;
			offset   := attribute.data.offset + attribute.data.buffer_view.offset;
			data := buffer + offset;
			log("Attribute %, %, %", to_string(attribute.name), attribute.data.count, attribute.data.stride);
			return data, attribute.data.count, attribute.data.stride; 
		}
	}
	return null, 0, 0;
}

load_gltf_file :: (arena: *Arena, path: string) -> [] *Mesh {
	meshes: [..]*Mesh;

	ATTRIBUTES_COUNT :: 3;
	attributes : [ATTRIBUTES_COUNT]string = .["POSITION", "NORMAL", "TEXCOORD_0"];
	
	options: cgltf_options;
	file_data: *cgltf_data;
	result := cgltf_parse_file(*options, path.data, *file_data);
	result = cgltf_load_buffers(*options, file_data, path.data);
	for i : 0..file_data.nodes_count - 1{
		node := *file_data.nodes[i];
		if node.mesh{
			mesh: *Mesh = arena_push(arena, Mesh);
			
			log("%", to_string(node.name));
			for j : 0..node.mesh.primitives_count - 1{
				primitive := *node.mesh.primitives[j];

				count : u64;
				summed_strides : u64;
				addressess : [ATTRIBUTES_COUNT] *u8; 
				strides : [ATTRIBUTES_COUNT] u64;
				
				for attributes {
					data, data_count, data_stride := get_gltf_attribute_data(primitive, it);
					addressess[it_index] = data;
					strides[it_index] = xx data_stride;
					count = max(count, data_count);
					summed_strides += data_stride;
				}
				
				data : *Vertex = arena_push(arena, count * size_of(Vertex));
				for i : 0..count - 1{
					data[i].position = cast(*Vec3, addressess[0] + strides[0] * i);
					data[i].normal = cast(*Vec3, addressess[1] + strides[1] * i);
					uvs := cast(*Vec2, addressess[2] + strides[2] * i).*;
					data[i].uv_x = uvs.x;
					data[i].uv_y = uvs.y;
					data[i].color.xyz = data[i].normal;
				}
				mesh.vertices = data;
				mesh.vertices_count = count;
				
				if primitive.indices {
					buffer  := primitive.indices.buffer_view.buffer.data;
                    offset  := primitive.indices.offset + primitive.indices.buffer_view.offset;
                    data := buffer + offset;
					if(data){
						mesh.indices_count = xx primitive.indices.count;
						if primitive.indices.component_type == {
							case .cgltf_component_type_r_16u;
								mesh.indices = cast(*u32, arena_push(arena, u16, primitive.indices.count));
								for i : 0..mesh.indices_count - 1{
									mesh.indices[i] =  xx cast(*u16, data)[i];
								}
							case .cgltf_component_type_r_32u;
								mesh.indices = arena_push(arena, u32, primitive.indices.count);
								memcpy(mesh.indices, data, cast(s64, size_of(u32) * primitive.indices.count));
						}
					}else{
						assert(false, "Not yet implemented");
					}
				}
			}

			mesh.buffer = allocate_mesh_on_gpu(mesh.vertices, xx mesh.vertices_count, mesh.indices, xx mesh.indices_count);
			
			array_add(*meshes, mesh);
		}
	}
	
	return meshes;
}
