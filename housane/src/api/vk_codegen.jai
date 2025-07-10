__sanitize_vk_type :: (type_name: string) -> string{
	copy := to_lower_copy(type_name,, temp);
	if copy[0] == #char "*"{
		copy.data += 1;
		copy.count -= 1;
	}

	if copy[copy.count - 2] == #char "_" && copy[copy.count - 1] == #char "t"{
		copy.count -= 2;
	}
	return copy;
}

__generate_deletion_queue_body :: ($type: ..Type) -> string{
	string_builder: String_Builder;
    init_string_builder(*string_builder);
	defer reset(*string_builder);

	for type {
		it_str := tprint("%", it);
		queue_name := __sanitize_vk_type(it_str);
		if queue_name[0] == #char "*"{
			queue_name.data += 1;
			queue_name.count -= 1;
		}
		append(*string_builder, tprint("%_queue: [..]%;\n", queue_name, it_str));
	}

	append(*string_builder, tprint("\npush :: (queue: *Deletion_Queue, handle: $T) {\n\tif !queue then return;\n\t#if T == {\n"));
	for type {
		it_str := tprint("%", it);
		queue_name := __sanitize_vk_type(it_str);
		append(*string_builder, tprint("\t\tcase %;\n\t\t\tarray_add(*queue.%_queue, handle);\n", it_str, queue_name));
	}
	
	append(*string_builder, tprint("\t\tcase;\n\t\t\tlog_error(\"Not supported type(\%) was tried to be pushes on the deletion queue\", T);\n\t}\n}\n"));

	append(*string_builder, tprint("\nflush :: (queue: *Deletion_Queue) {\n"));
	for type {
		it_str := tprint("%", it);
		queue_name := __sanitize_vk_type(it_str);
		append(*string_builder, tprint("\tfor *< queue.%0_queue {\n\t\tdestroy_%(it);\n\t}\n\tqueue.%0_queue.count = 0;\n", queue_name, queue_name, queue_name));
	}
	append(*string_builder, tprint("}"));
	
    return builder_to_string(*string_builder);
}
