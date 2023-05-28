--short cuts
require("TMP_libs.short_cuts.load_2D_map")
require("TMP_libs.short_cuts.create_text")
require("TMP_libs.short_cuts.create_sound")
require("TMP_libs.short_cuts.create_mesh")
require("TMP_libs.short_cuts.create_camera")
require("TMP_libs.short_cuts.create_collision_mesh")
require("TMP_libs.short_cuts.create_render_shader")
require("TMP_libs.objects.post_processing")
require("TMP_libs.objects.window")
require("TMP_libs.objects.collision_shapes")


require("TMP_libs.components.component_all")

require("TMP_libs.layers_table")




function extract_object_properties(object)
    ret = {}
    name = ""
    value = {}
    if object.properties ~= nil then
        for p_id,p in ipairs(object.properties) do
            ret[p.name] = p.value
        end
        ret[name] = value
    end
    return ret
end

function initialize_render_settings()
    
    window.resolution.x = 720
    window.resolution.y = 720
    window:set()
    

    renders_layers.layers_size = 4

    renders_layers.layers[1] = render_layer:new()
    renders_layers.layers[1].end_render = false
    renders_layers.layers[1].use_deeph = true
    renders_layers.layers[1].clean_color = false
    renders_layers.layers[1].start_render = true

    renders_layers.layers[2] = render_layer:new()
    renders_layers.layers[2].end_render = false
    renders_layers.layers[2].use_deeph = true
    renders_layers.layers[2].clean_color = false
    renders_layers.layers[2].start_render = false

    renders_layers.layers[3] = render_layer:new()
    renders_layers.layers[3].end_render = true
    renders_layers.layers[3].use_deeph = true
    renders_layers.layers[3].clean_color = false
    renders_layers.layers[3].start_render = false

    renders_layers:set()

    post_processing:get()
    post_processing.material.shader = "resources/Shaders/post_processing"
    post_processing:set()
    
end






this_sceane = {}
this_sceane.camera = nil
this_sceane.tile_map_info = nil
this_sceane.background = nil
this_sceane.objects_layesrs = nil


function this_sceane:unload()
    print("unloading sceane")
    this_sceane.objects_layesrs:destroy()
    clear_memory()
end

function create_background(image)
    background_material = material:new()
    background_material.shader = "resources/Shaders/background"
    background_material.textures[1] = image
    this_sceane.background = create_render_shader(this_sceane.objects_layesrs.background_image,false,Vec3:new(0, 0, 0),Vec3:new(0, 0, 0),Vec3:new(1, 1, 1),1,background_material)
end

function create_colision_tiled_box_volume(pos,rot,sca,debug)
    ret = game_object:new(create_object(this_sceane.tile_map_info.map_object.object_ptr))

    

    ret:add_component(components.physics_2D)
    ret.components[components.physics_2D].scale = Vec2:new(sca.x,sca.y)
    ret.components[components.physics_2D].colision_shape = collision_shapes.tiled_volume
    ret.components[components.physics_2D].rotate = false
    ret.components[components.physics_2D]:set()

    ret:add_component(components.transform)
    ret.components[components.transform].position = deepcopy(pos)
    ret.components[components.transform].rotation = deepcopy(rot)
    ret.components[components.transform].scale = deepcopy(Vec3:new(sca.x,sca.y,sca.z))
    ret.components[components.transform]:set()
    ret.components[components.transform]:change_position(pos.x,pos.y,pos.z)
    ret.components[components.transform]:change_rotation(rot.x,rot.y,rot.z)

    if debug then
        ret:add_component(components.render_sprite)
        ret.components[components.render_sprite].layer = 2
        ret.components[components.render_sprite].selected_tile = 1
        ret.components[components.render_sprite].tile_set_local = "resources/Leveis 2D/tilesets/tileset.json"
        mat = material:new()
        mat.shader = "resources/Shaders/tiled_volume"
        mat.color = {r=0,g=1,b=0,a=1}
        ret.components[components.render_sprite].material = deepcopyjson(mat)
        ret.components[components.render_sprite]:set()
    end
    

    return ret
end

function create_crate(pos)
    ret = game_object:new(create_object(this_sceane.tile_map_info.map_object.object_ptr))
    set_gravity(0,-9,0)
    

    ret:add_component(components.physics_2D)
    ret.components[components.physics_2D].scale = Vec2:new(1,1)
    ret.components[components.physics_2D].colision_shape = collision_shapes.box
    ret.components[components.physics_2D].boady_dynamic =  boady_dynamics.dynamic
    ret.components[components.physics_2D].rotate = true
    ret.components[components.physics_2D].friction = 1
    ret.components[components.physics_2D]:set()
    

    ret:add_component(components.transform)
    ret.components[components.transform].position = deepcopy(pos)
    ret.components[components.transform]:set()
    ret.components[components.transform]:change_position(pos.x,pos.y,pos.z)
    ret.components[components.transform]:change_rotation(rot.x,rot.y,rot.z)

    ret:add_component(components.render_sprite)
    ret.components[components.render_sprite].layer = 2
    ret.components[components.render_sprite].selected_tile = 25
    ret.components[components.render_sprite].tile_set_local = "resources/Leveis 2D/tilesets/tileset.json"
    mat = material:new()
    mat.shader = "resources/Shaders/sprite"
    --mat.color = {r=0,g=1,b=0,a=1}
    ret.components[components.render_sprite].material = deepcopyjson(mat)
    ret.components[components.render_sprite]:set()

    ret:add_component(components.lua_scripts)
    ret.components[components.lua_scripts]:add_script("resources/Scripts/collision_debuger.lua")
    --collision_debuger.lua
end



function create_tilemap(tilemap_path,tileset_path,image_folder)
    tile_map_material = material:new()
    tile_map_material.shader = "resources/Shaders/sprite"
    this_sceane.tile_map_info = load_2D_map(this_sceane.objects_layesrs.cenary,Vec3:new(0,0,0),Vec3:new(0,90,0),Vec3:new(1,1,1),tilemap_path,tileset_path,image_folder,tile_map_material)
    this_sceane.tile_map_info.map_object.components[components.render_tile_map].render_tilemap_only_layer = -1
    this_sceane.tile_map_info.map_object.components[components.render_tile_map]:set()

    

    --get info
    tile_map_info_size = {
        x=this_sceane.tile_map_info.tile_map_info.width,
        y=this_sceane.tile_map_info.tile_map_info.height,
        tile_x=this_sceane.tile_map_info.tile_map_info.tilewidth,
        tile_y=this_sceane.tile_map_info.tile_map_info.tileheight,
    }

    tile_map_layer_info_map = {}
    for l_id,l in  ipairs(this_sceane.tile_map_info.tile_map_info.layers) do
        tile_map_layer_info_map[l.name] = deepcopyjson(l)
    end
    
    tile_set_info_map = {}
    for t_id,t in ipairs(this_sceane.tile_map_info.tile_set_info.tiles) do
        tile_set_info_map[t.id] = deepcopyjson(t)
    end
    
    --create_collision
    for v_id,v in ipairs(tile_map_layer_info_map["collision"].objects) do
        
        sca = Vec3:new((v.width / tile_map_info_size.tile_x) * 2 ,(v.height / tile_map_info_size.tile_y) * 2 ,0)
        pos = Vec3:new((v.x * 2)  / tile_map_info_size.tile_x,(-v.y * 2)  / tile_map_info_size.tile_y,0)
        pos = Vec3:new(pos.x -1 ,pos.y + 1  ,0)
        rot = Vec3:new(v.rotation,0,0)
        create_colision_tiled_box_volume(pos,rot,sca,false)
    end
    
    
    for o_id,o in ipairs(tile_map_layer_info_map["objects"].objects) do
        properties = extract_object_properties(o)
        pos = Vec3:new((o.x * 2)  / tile_map_info_size.tile_x,(-o.y * 2)  / tile_map_info_size.tile_y,0)
        pos = Vec3:new(pos.x - 1 ,pos.y + 1  ,0)
        if properties.name == "player_start" then
        elseif properties.name  == "crate" then
            
            create_crate(pos)
        elseif properties.name == "3D_model" then
            mat = material:new()
            mat.shader = "resources/Shaders/mesh"
            create_mesh(this_sceane.objects_layesrs.background_3D,false,pos,Vec3:new(0,45,0),Vec3:new(1,1,1),2,{mat},{mesh_location:new(properties.model_file,properties.model_name)})
        elseif properties.name == "raycast_test" then
            mat = matreial:new()
            mat.shader = "resources/Shaders/mesh"
            mat.color = {r = 1,g = 0,b = 0,a = 1}
            create_mesh(this_sceane.objects_layesrs.background_3D,false,pos,Vec3:new(0,0,0),Vec3:new(1,1,1),2,{mat},{mesh_location:new("resources/3D Models/cube.obj","Cube")})
            
            
        end
    end
end


sceanes_db = {}



sceanes_db.test = {}
function sceanes_db.test:load()
    print("loading test map")
    initialize_render_settings()
    this_sceane.objects_layesrs = layers_table:new_2D()
    this_sceane.objects_layesrs:create()
    
    create_audio(this_sceane.objects_layesrs.sound,"resources/Audio/teste de audio.wav",true,5)
    --background
    
    create_background("resources/Textures/fundo A.png")

    --camera
    this_sceane.camera = create_camera_ortho(this_sceane.objects_layesrs.camera,Vec3:new(-10, 0, 0),Vec3:new(0, 0, 0),150,150,720,720,0.1,100)
    set_lisener_object(this_sceane.camera.object_ptr)

    --tilemap
    create_tilemap("resources/Leveis 2D/tilemaps/tilemap.json","resources/Leveis 2D/tilesets/tileset.json","resources/Leveis 2D/tilesets")
    mat = material:new()
    mat.shader = "resources/Shaders/text"
    create_text(this_sceane.objects_layesrs.hud,true,Vec3:new(-0.75,0.75,0.9),Vec3:new(0,0,0),Vec3:new(0.05,0.05,0.05),mat,3,"Ãa._AlL BBbBB\nçççççç","resources/Fonts/Glowworm Regular.json")
    
    
end


sceanes_db.test2 = {}
function sceanes_db.test2:load()
    print("loading test map")
    initialize_render_settings()
    this_sceane.objects_layesrs = layers_table:new_2D()
    this_sceane.objects_layesrs:create()
    
    --create_audio(this_sceane.objects_layesrs.sound,"resources/Audio/teste de audio.wav",true,5)
    --background
    
    create_background("resources/Textures/fundo A.png")

    --camera
    --this_sceane.camera = create_camera_ortho(this_sceane.objects_layesrs.camera,Vec3:new(-10, 0, 0),Vec3:new(0, 0, 0),150,150,720,720,0.1,100)
    this_sceane.camera = create_camera_perspective(this_sceane.objects_layesrs.camera,Vec3:new(-10, 0, 0),Vec3:new(0, 0, 0),90,0.1,100)
    set_lisener_object(this_sceane.camera.object_ptr)

    mat = matreial:new()
    mat.shader = "resources/Shaders/mesh"
    mat.color = {r = 1,g = 0,b = 0,a = 1}       
    pos = Vec3:new(0,0,0)
    create_mesh(this_sceane.objects_layesrs.background_3D,false,pos,Vec3:new(0,-90,0),Vec3:new(1,1,1),2,{mat},{mesh_location:new("resources/3D Models/cube.gltf","Suzanne")})
    
    
end


sceanes_db.test3 = {}
function sceanes_db.test3:load()
    print("loading test map")
    initialize_render_settings()
    this_sceane.objects_layesrs = layers_table:new_2D()
    this_sceane.objects_layesrs:create()
    
    --create_audio(this_sceane.objects_layesrs.sound,"resources/Audio/teste de audio.wav",true,5)
    
    create_background("resources/Textures/fundo A.png")

    --camera
    this_sceane.camera = create_camera_perspective(this_sceane.objects_layesrs.camera,Vec3:new(-10, 0, 0),Vec3:new(0, 0, 0),90,0.1,100)
    set_lisener_object(this_sceane.camera.object_ptr)

    mat = matreial:new()
    mat.shader = "resources/Shaders/mesh"
    mat.color = {r = 1,g = 0,b = 0,a = 1}
    mat.textures = {"resources/Textures/white.png"}  
    pos = Vec3:new(0,0,0)

    suzane_mesh = mesh_location:new("resources/3D Models/cube.gltf","Suzanne")
    set_gravity(0,-9,0)
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,5,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)

    mat.color = {r = 0,g = 0,b = 0,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,5,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)

    mat.color = {r = 0,g = 1,b = 0,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,10,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{mesh_location:new("resources/3D Models/cube.gltf","Cube")},true,collision_shapes.cube,mesh_location:new("resources/3D Models/cube.gltf","Cube"))

    mat.color = {r = 0,g = 0,b = 1,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,7,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)
    
    mat.color = {r = 1,g = 1,b = 1,a = 1}
    collis_detect = create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,-5,0),Vec3:new(0,45,0),Vec3:new(100,1,100),2,{mat},{mesh_location:new("resources/3D Models/cube.gltf","Cube")},false,collision_shapes.cube,mesh_location:new("resources/3D Models/cube.gltf","Cube"))

end

sceanes_db.test4 = {}
function sceanes_db.test4:load()
    print("loading test map")
    initialize_render_settings()
    this_sceane.objects_layesrs = layers_table:new_2D()
    this_sceane.objects_layesrs:create()
    
    create_background("resources/Textures/fundo A.png")

    --camera
    this_sceane.camera = create_camera_perspective(this_sceane.objects_layesrs.camera,Vec3:new(-10, 0, 0),Vec3:new(0, 0, 0),90,0.1,100)
    set_lisener_object(this_sceane.camera.object_ptr)

    mat = matreial:new()
    mat.shader = "resources/Shaders/mesh"
    mat.color = {r = 1,g = 0,b = 0,a = 1}
    mat.textures = {"resources/Textures/white.png"}  
    pos = Vec3:new(0,0,0)

    suzane_mesh = mesh_location:new("resources/3D Models/cube.gltf","Suzanne")
    set_gravity(0,-9,0)
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,5,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)

    mat.color = {r = 0,g = 0,b = 0,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,5,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)

    mat.color = {r = 0,g = 1,b = 0,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,10,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{mesh_location:new("resources/3D Models/cube.gltf","Cube")},true,collision_shapes.cube,mesh_location:new("resources/3D Models/cube.gltf","Cube"))

    mat.color = {r = 0,g = 0,b = 1,a = 1}
    create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,7,0),Vec3:new(44,-90,0),Vec3:new(1,1,1),2,{mat},{suzane_mesh},true,collision_shapes.convex,suzane_mesh)
    
    mat.color = {r = 1,g = 1,b = 1,a = 1}
    collis_detect = create_collision_mesh(this_sceane.objects_layesrs.background_3D,Vec3:new(0,-5,0),Vec3:new(0,45,0),Vec3:new(100,1,100),2,{mat},{mesh_location:new("resources/3D Models/cube.gltf","Cube")},false,collision_shapes.cube,mesh_location:new("resources/3D Models/cube.gltf","Cube"))
end