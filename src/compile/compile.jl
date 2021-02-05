function compile!(agentModel::Model;platform="cpu",
    integrator="euler",saveRAM = false,saveVTK = false,positionsVTK=[:x,:y,:z], debug = false)

varDeclarations = []
fDeclarations = []
execute = []
kArgs = []
initialisation = []

#Neighbours declare
if typeof(agentModel.neighborhood) in keys(NEIGHBOURS)
    var,f,execNN, inLoop, arg = NEIGHBOURS[typeof(agentModel.neighborhood)](agentModel,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,execNN)
else
    error("No neigborhood called ", agentModel.neighborhood,".")
end

#Parameter declare
var,f,exec,begining = parameterAdapt(agentModel,inLoop,arg,platform=platform)
append!(varDeclarations,var)
append!(fDeclarations,f)
append!(execute,exec)
append!(initialisation,begining)   

#Integrator
if integrator in keys(INTEGRATORS)
    var,f,exec,begining = INTEGRATORS[integrator](agentModel,inLoop,arg,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,exec)     
    append!(initialisation,begining)   
elseif integrator in keys(INTEGRATORSSDE)
    var,f,exec,begining = INTEGRATORSSDE[integrator](agentModel,inLoop,arg,platform=platform)
    integratorFound = true
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,exec)
    append!(initialisation,begining)   
else
    error("No integrator called ", integrator,".")
end

#Special functions
for special in agentModel.special
    var,f,execS,begining = SPECIAL[typeof(special)](special,agentModel,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,execS)    
    append!(initialisation,begining)   
end

#Saving
saving = false
execSaveList = []
execSaveFinal = []
if saveRAM
    var,f,exec = saveRAMCompile(agentModel)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execSaveList,exec)
    ret=[:(commRAM_)]

    saving = true
else
    execSave = []
    ret=[:Nothing]
end

if saveVTK
    var,f,exec,final,kargs = saveVTKCompile(agentModel,positionsVTK)
    append!(varDeclarations,var)
    append!(fDeclarations,f)  
    append!(execSaveList,exec)
    append!(execSaveFinal,final)
    append!(kArgs,kargs)

    saving = true
end

if saving == true
    push!(varDeclarations,:(countSave = 1))
    execSave = [:(
    if t >= tSave_
        $(execSaveList...)
        tSave_ += tSaveStep_
        countSave += 1
    end    
    )]
else
    execSave = []
end

program = :(
function (com::Community;$(kArgs...),tMax_, dt, t=com.t, N=com.N, nMax_=com.N, neighMax_=nMax_, tSave_=0., tSaveStep_=dt, threads_=256)
    #Declaration of variables
    $(varDeclarations...)
    #Declaration of functions
    $(fDeclarations...)
        
    #println(CUDA.memory_status())
    
    #Execution of the program
    nBlocks_ = min(round(Int,N/threads_),2560)
    if nBlocks_ == 0
        nBlocks_ = 1
    end
    
    $(execNN...)
    $(initialisation...)
    $(initialisation...)
    $(execSave...)
    while t <= tMax_
        nBlocks_ = min(round(Int,N/threads_),2560)
        if nBlocks_ == 0
            nBlocks_ = 1
        end
        #println(nBlocks_)
        $(execute...)

        t += dt

        $(execSave...)
    end

    $(execSaveFinal...)
        
    #CUDA.unsafe_free!(loc_)
    #CUDA.unsafe_free!(locInter_)
    #CUDA.unsafe_free!(nnN_)
    #CUDA.unsafe_free!(nnList_)
        
    return $(ret...)
end
)

if debug == true
    clean(program)
end

agentModel.evolve = Base.MainInclude.eval(program)

return

end



function precompile!(agentModel::Model;platform="cpu",
    integrator="euler",saveRAM = false,saveVTK = false,positionsVTK=[:x,:y,:z], debug = false)

varDeclarations = []
fDeclarations = []
execute = []
kArgs = []
initialisation = []

#Neighbours declare
if typeof(agentModel.neighborhood) in keys(NEIGHBOURS)
    var,f,execNN, inLoop, arg = NEIGHBOURS[typeof(agentModel.neighborhood)](agentModel,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,execNN)
else
    error("No neigborhood called ", agentModel.neighborhood,".")
end

#Parameter declare
var,f,exec,begining = parameterAdapt(agentModel,inLoop,arg,platform=platform)
append!(varDeclarations,var)
append!(fDeclarations,f)
append!(execute,exec)
append!(initialisation,begining)   

#Integrator
if integrator in keys(INTEGRATORS)
    var,f,exec,begining = INTEGRATORS[integrator](agentModel,inLoop,arg,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,exec)     
    append!(initialisation,begining)   
elseif integrator in keys(INTEGRATORSSDE)
    var,f,exec,begining = INTEGRATORSSDE[integrator](agentModel,inLoop,arg,platform=platform)
    integratorFound = true
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,exec)
    append!(initialisation,begining)   
else
    error("No integrator called ", integrator,".")
end

#Special functions
for special in agentModel.special
    var,f,execS,begining = SPECIAL[typeof(special)](special,agentModel,platform=platform)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execute,execS)    
    append!(initialisation,begining)   
end

#Saving
saving = false
execSaveList = []
execSaveFinal = []
if saveRAM
    var,f,exec = saveRAMCompile(agentModel)
    append!(varDeclarations,var)
    append!(fDeclarations,f)
    append!(execSaveList,exec)
    ret=[:(commRAM_)]

    saving = true
else
    execSave = []
    ret=[:Nothing]
end

if saveVTK
    var,f,exec,final,kargs = saveVTKCompile(agentModel,positionsVTK)
    append!(varDeclarations,var)
    append!(fDeclarations,f)  
    append!(execSaveList,exec)
    append!(execSaveFinal,final)
    append!(kArgs,kargs)

    saving = true
end

if saving == true
    push!(varDeclarations,:(countSave = 1))
    execSave = [:(
    if t >= tSave_
        $(execSaveList...)
        tSave_ += tSaveStep_
        countSave += 1
    end    
    )]
else
    execSave = []
end

program = :(
function (com::Community;$(kArgs...),tMax_, dt, t=com.t, N=com.N, nMax_=com.N, neighMax_=nMax_, tSave_=0., tSaveStep_=dt, threads_=256)
    #Declaration of variables
    $(varDeclarations...)
    #Declaration of functions
    $(fDeclarations...)
        
    #println(CUDA.memory_status())
    
    #Execution of the program
    nBlocks_ = min(round(Int,N/threads_),2560)
    if nBlocks_ == 0
        nBlocks_ = 1
    end
    
    $(execNN...)
    $(initialisation...)
    $(initialisation...)
    $(execSave...)
    while t <= tMax_
        nBlocks_ = min(round(Int,N/threads_),2560)
        if nBlocks_ == 0
            nBlocks_ = 1
        end
        #println(nBlocks_)
        $(execute...)

        t += dt

        $(execSave...)
    end

    $(execSaveFinal...)
        
    #CUDA.unsafe_free!(loc_)
    #CUDA.unsafe_free!(locInter_)
    #CUDA.unsafe_free!(nnN_)
    #CUDA.unsafe_free!(nnList_)
        
    return $(ret...)
end
)

if debug == true
    clean(program)
end

agentModel.evolve = eval(program)

return

end
