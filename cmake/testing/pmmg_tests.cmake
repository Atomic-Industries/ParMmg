IF( BUILD_TESTING )
  include( CTest )

  set( CI_DIR  ${CMAKE_BINARY_DIR}/Tests )
  file( MAKE_DIRECTORY ${CI_DIR} )
  set( CI_DIR_RESULTS  ${CI_DIR}/TEST_OUTPUTS )
  file( MAKE_DIRECTORY ${CI_DIR_RESULTS} )
  set( CI_DIR_INPUTS  "../../testparmmg" CACHE PATH "path to test meshes repository" )

  # remesh 2 sets of matching mesh/sol files (which are the output of mmg3d)
  # on 1,2,4,6,8 processors
  foreach( MESH cube-unit-dual_density cube-unit-int_sphere )
    foreach( NP 1 2 4 6 8 )
      add_test( NAME ${MESH}-${NP}
        COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
        ${CI_DIR_INPUTS}/Cube/${MESH}.mesh
        -out ${CI_DIR_RESULTS}/${MESH}-${NP}-out.mesh
        -m 11000 )
    endforeach()
  endforeach()

  # remesh a unit cube with two different solution files on 1,2,4,6,8 processors
  foreach( MESH dual_density int_sphere )
    foreach( NP 1 2 4 6 8 )
      add_test( NAME cube-unit-coarse-${MESH}-${NP}
        COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
        ${CI_DIR_INPUTS}/Cube/cube-unit-coarse.mesh
        -sol ${CI_DIR_INPUTS}/Cube/cube-unit-coarse-${MESH}.sol
        -out ${CI_DIR_RESULTS}/${MESH}-${NP}-out.mesh )
    endforeach()
  endforeach()

  # remesh a non constant anisotropic test case: a torus with a planar shock
  # on 1,2,4,6,8 processors
  foreach( TYPE anisotropic-test )
    foreach( NP 1 2 4 6 8 )
      add_test( NAME ${TYPE}-torus-with-planar-shock-${NP}
        COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
        ${CI_DIR_INPUTS}/Torus/torusholes.mesh
        -sol ${CI_DIR_INPUTS}/Torus/torusholes.sol
        -out ${CI_DIR_RESULTS}/${TYPE}-torus-with-planar-shock-${NP}-out.mesh )
    endforeach()
  endforeach()

  ###############################################################################
  #####
  #####        Tests options (on 1, 6 and 8 procs)
  #####
  ###############################################################################

  # Default option: no metric
  foreach( NP 1 6 8 )
    add_test( NAME Sphere-${NP}
      COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
      ${CI_DIR_INPUTS}/Sphere/sphere.mesh
      -out ${CI_DIR_RESULTS}/sphere-${NP}-out.mesh )
  endforeach()

  # Option without arguments
  foreach( OPTION "optim" "optimLES" "nosurf" "noinsert" "noswap"  )
    foreach( NP 1 6 8 )
      add_test( NAME Sphere-optim-${OPTION}-${NP}
        COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
        -${OPTION}
        ${CI_DIR_INPUTS}/Sphere/sphere.mesh
        -out ${CI_DIR_RESULTS}/sphere-${OPTION}-${NP}-out.mesh )
    endforeach()
  endforeach()

  # Option with arguments
  SET ( OPTION
    "-v 5"
    "-hsiz 0.02"
    "-hausd 0.005"
    "-hgrad 1.1"
    "-hgrad -1"
    "-hmax 0.05"
    "-nr"
    "-ar 10" )

  SET ( NAME
    "v5"
    "hsiz0.02"
    "hausd0.005"
    "hgrad1.1"
    "nohgrad"
    "hmax0.05"
    "nr"
    "ar10" )

  LIST(LENGTH PMMG_LIB_TESTS nbTests_tmp)
  MATH(EXPR nbTests "${nbTests_tmp} - 1")

  FOREACH ( test_idx RANGE ${nbTests} )
    LIST ( GET OPTION  ${test_idx} test_option )
    LIST ( GET NAME    ${test_idx} test_name )

    FOREACH( NP 1 6 8 )
      add_test( NAME Sphere-optim-${test_name}-${NP}
        COMMAND ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP} $<TARGET_FILE:${PROJECT_NAME}>
        ${test_option}
        ${CI_DIR_INPUTS}/Sphere/sphere.mesh
        -out ${CI_DIR_RESULTS}/sphere-${test_name}-${NP}-out.mesh )
    ENDFOREACH()
  ENDFOREACH ( )




  ###############################################################################
  #####
  #####        Tests that needs the PARMMG LIBRARY
  #####
  ###############################################################################

  SET ( PMMG_LIB_TESTS
    libparmmg_centralized_auto_example0
    libparmmg_centralized_manual_example0_io_0
    libparmmg_centralized_manual_example0_io_1
    )

  SET ( PMMG_LIB_TESTS_MAIN_PATH
    ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/automatic_IO/main.c
    ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/manual_IO/main.c
    ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/manual_IO/main.c
    )

  SET ( PMMG_LIB_TESTS_INPUTMESH
    ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/cube.mesh
    ""
    ""
    )

  SET ( PMMG_LIB_TESTS_INPUTMET
    ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/cube-met.sol
    ""
    ""
    )

  SET ( PMMG_LIB_TESTS_INPUTSOL
    ""
    ""
    ""
    )

  SET ( PMMG_LIB_TESTS_OUTPUTMESH
    ${CI_DIR_RESULTS}/io-seq-auto-cube.o.mesh
    ${CI_DIR_RESULTS}/io-seq-manual-cube_io_0.o
    ${CI_DIR_RESULTS}/io-seq-manual-cube_io_1.o
    )

  SET ( PMMG_LIB_TESTS_OPTIONS
    "-met"
    "0"
    "1"
    )

  IF ( LIBPARMMG_STATIC )
    SET ( lib_name lib${PROJECT_NAME}_a )
  ELSEIF ( LIBPARMMG_SHARED )
    SET ( lib_name lib${PROJECT_NAME}_so )
  ELSE ()
    MESSAGE(WARNING "You must activate the compilation of the static or"
      " shared ${PROJECT_NAME} library to compile this tests." )
  ENDIF ( )

  #####         Fortran Tests
  IF ( CMAKE_Fortran_COMPILER )
    ENABLE_LANGUAGE ( Fortran )

    FIND_PACKAGE( MPI COMPONENTS Fortran REQUIRED )

    IF ( MPI_Fortran_FOUND )
      SET( CMAKE_Fortran_COMPILE_FLAGS "${CMAKE_Fortran_COMPILE_FLAGS} ${MPI_COMPILE_FLAGS}" )
      SET( CMAKE_Fortran_LINK_FLAGS "${CMAKE_Fortran_LINK_FLAGS} ${MPI_LINK_FLAGS}" )
      SET( FORTRAN_LIBRARIES ${MPI_Fortran_LIBRARIES} )

    ELSE ( )
      MESSAGE(FATAL_ERROR " Fortran MPI library not found")
    ENDIF ( )


    LIST ( APPEND PMMG_LIB_TESTS libparmmg_fortran_centralized_auto_example0
      # libparmmg_centralized_manual_example0_io_0
      # libparmmg_centralized_manual_example0_io_1
      )

    LIST ( APPEND PMMG_LIB_TESTS_MAIN_PATH
      ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/automatic_IO/main.F90
      # ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/manual_IO/main.c
      # ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/sequential_IO/manual_IO/main.c
      )

    LIST ( APPEND PMMG_LIB_TESTS_INPUTMESH
      ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/cube.mesh
      #""
      #""
      )

    LIST ( APPEND PMMG_LIB_TESTS_INPUTMET
      ${PROJECT_SOURCE_DIR}/libexamples/adaptation_example0/cube-met.sol
     # ""
     # ""
     )

    LIST ( APPEND PMMG_LIB_TESTS_INPUTSOL
      ""
      #""
      #""
      )

    LIST ( APPEND PMMG_LIB_TESTS_OUTPUTMESH
      ${CI_DIR_RESULTS}/io-seq-auto-cube.o.mesh
      #${CI_DIR_RESULTS}/io-seq-manual-cube_io_0.o
      #${CI_DIR_RESULTS}/io-seq-manual-cube_io_1.o
       )

     LIST ( APPEND PMMG_LIB_TESTS_OPTIONS
      "-met"
      #"0"
      #"1"
      )
  ENDIF ( CMAKE_Fortran_COMPILER )


  LIST(LENGTH PMMG_LIB_TESTS nbTests_tmp)
  MATH(EXPR nbTests "${nbTests_tmp} - 1")

  FOREACH ( test_idx RANGE ${nbTests} )
    LIST ( GET PMMG_LIB_TESTS            ${test_idx} test_name )
    LIST ( GET PMMG_LIB_TESTS_MAIN_PATH  ${test_idx} main_path )
    LIST ( GET PMMG_LIB_TESTS_INPUTMESH  ${test_idx} input_mesh )
    LIST ( GET PMMG_LIB_TESTS_INPUTMET   ${test_idx} input_met )
    LIST ( GET PMMG_LIB_TESTS_INPUTSOL   ${test_idx} input_sol )
    LIST ( GET PMMG_LIB_TESTS_OUTPUTMESH ${test_idx} output_mesh )
    LIST ( GET PMMG_LIB_TESTS_OPTIONS    ${test_idx} options )

    LIST ( APPEND lib_name ${FORTRAN_LIBRARIES})

    ADD_LIBRARY_TEST ( ${test_name} ${main_path} copy_pmmg_headers "${lib_name}" )

    FOREACH( NP 1 2 6 )
      ADD_TEST ( NAME ${test_name}-${NP} COMMAND  ${MPIEXEC} ${MPI_ARGS} ${MPIEXEC_NUMPROC_FLAG} ${NP}
        $<TARGET_FILE:${test_name}>
        ${input_mesh} ${output_mesh} ${options} ${input_met} )
    ENDFOREACH()

  ENDFOREACH ( )

  # Sequential test
  SET ( test_name  LnkdList_unitTest )
  SET ( main_path  ${CI_DIR_INPUTS}/LnkdList_unitTest/main.c )

  ADD_LIBRARY_TEST ( ${test_name} ${main_path} copy_pmmg_headers "${lib_name}" )
  ADD_TEST ( NAME ${test_name} COMMAND $<TARGET_FILE:${test_name}> )


ENDIF()
