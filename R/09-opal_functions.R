#' @title
#' Create a project in an Opal environment
#'
#' @description
#' Creates an empty project in an Opal environment. This is a wrapper function 
#' for [opalr::opal.project_create()].
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#' 
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#'
#' @param opal Opal login attributes.
#' @param project A character string to name the project in Opal.
#' @param tag A character string to provide a tag for the Opal project.
#'
#' @returns
#' A project in an Opal environment. If the project already exists, it
#' will remain as it is, and no new project is created.
#' The user must have adequate credentials to interact with their Opal
#' environment.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <-
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'
#' tempdir <- basename(tempdir())
#' try(opal_project_create(opal, tempdir))
#' 
#' }
#'
#' @import dplyr opalr
#' @importFrom rlang .data
#'
#' @export
opal_project_create <- function(opal, project, tag = NULL){

  if(!is.null(tag)){tag <- as.list(tag)}
  for(i in project){
    # stop()}

    if(opal.project_exists(opal = opal, project = basename(i))){
      message(
"The project ",i," already exists in Opal and will not be created here.")

    }else{

      opal.project_create(
        opal = opal,
        project = basename(i),
        database = TRUE,
        tags = tag)
      message("The project ",i," has been created in Opal")
    }
  }
}

#' @title
#' Upload files to an Opal environment
#'
#' @description
#' Uploads files from the local environment to an Opal environment. This is a 
#' wrapper function for [opalr::opal.file_upload()].
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#'
#' @param opal Opal login attributes.
#' @param from A character string of a path where the files will be taken from
#' in R.
#' @param to A character string of a path where the files will be placed to in
#' Opal.
#'
#' @returns
#' Folder(s) containing files coming from the user R environment in Opal.
#' The path to Opal needs to be pasted with Opal absolute path.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'   
#' tempdir <- tempdir()
#' invisible(dir.create(paste0(tempdir,"/a_file")))
#' invisible(file.create(paste0(tempdir,"/a_file","/file.txt")))
#' try(opal_files_push(opal, from = paste0(tempdir,"/a_file"), to = tempdir))
#' 
#' }
#'
#' @import dplyr opalr
#' @importFrom rlang .data
#'
#' @export
opal_files_push <- function(opal, from, to){

  opal.file_upload(opal = opal,source = from, destination = to)
  message("Your file(s) has(ve) been succesfully uploaded to Opal")
}

#' @title
#' Download files from an Opal environment
#' 
#' @description
#' Downloads files from an Opal environment to the local environment. This is a 
#' wrapper function for [opalr::opal.file_download()].
#' 
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#' 
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#'
#' @param opal Opal login attributes.
#' @param from A character string of a path where the files will be taken from
#' in R.
#' @param to A character string of a path where the files will be placed to in
#' Opal.
#'
#' @returns
#' Folder(s) containing files coming from Opal in user R environment.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'   
#' tempdir <- tempdir()
#' invisible(dir.create(paste0(tempdir,"/a_file")))
#' invisible(file.create(paste0(tempdir,"/a_file","/file.txt")))
#' try(opal_files_push(opal, from = paste0(tempdir,"/a_file"), to = tempdir))
#' try(opal_files_pull(opal, from = paste0(tempdir,"/a_file"), to = tempdir))
#' 
#' }
#'
#' @import dplyr stringr opalr tools
#' @importFrom rlang .data
#' @importFrom utils unzip
#'
#' @export
opal_files_pull <- function(opal, from, to){

  # if from = ".../.../foo"     and to = ".../.../fuu"
  #    then > zip the folder, dl and unzip
  # if from = ".../.../foo.ext" and to = ".../.../fuu"
  #    then > to <- to + "/" + basename(from), dl
  # if from = ".../.../foo.ext" and to = ".../.../fuu.ext"
  #    then >dl

  to <- ifelse(file_ext(from) == file_ext(to),to, paste0(to,"/",basename(from)))
  to <- ifelse(file_ext(to) == "",paste0(to,".zip"),to)
  to <- str_replace(to,"/.zip",".zip")

  if(from == ""){
    message("\nYou must provide an Opal files path\n")}else{

      tryCatch(
        {opal.file_download(
          opal = opal,
          source = from,
          destination = to)},
        error = function(cond){
          file.remove(paste0(to))
          stop(call. = FALSE,cond)})

      if(file_ext(to) == "zip"){
        unzip(zipfile = to,
              exdir = file_path_sans_ext(to),
              overwrite = TRUE,
              junkpaths = FALSE)
        file.remove(paste0(to))
        message(
          "The files have been added to your environment in the folder ",
          file_path_sans_ext(to),".\n")
      }else{
        message(
"The file ",
  basename(to)," have been added to your environment in the folder ",
   dirname(to),".\n")
      }
    }
}

#' @title
#' Upload datasets into an Opal environment as tables in an Opal project
#'
#' @description
#' Uploads a dossier or dataset from the local environment to an Opal
#' environment. This is a wrapper function for [opalr::opal.table_create()],
#' [opalr::opal.table_save()] and [opalr::opal.table_dictionary_update()].
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#' [madshapR::as_dossier()] 
#' [madshapR::as_dataset()]
#' [madshapR::as_data_dict_mlstr()]
#'
#' @param opal Opal login attributes.
#' @param dossier List of data frame, each of them being datasets.
#' @param dataset A tibble identifying the dataset observations associated to 
#' its data dictionary.
#' @param data_dict A list of tibble(s) representing metadata of an
#' associated dataset. Automatically generated if not provided.
#' @param project_name A character string specifying the Opal project name.
#' @param table_name A character string specifying an Opal table name.
#' @param .force If the destination already exists, stop with an informative
#' message if this flag is FALSE (default).
#' @param .overwrite If the destination table already exists, it will be
#' replaced (deleted, re-created with associated permissions reinstated and then
#' imported). Otherwise the table will be updated (data dictionaries merge may
#' conflict). Default is FALSE.*
#'
#' @returns
#' A table or table(s) in Opal.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'     
#' # use madshapR_DEMO provided by the package
#' library(madshapR)
#' library(stringr)
#' dataset <- madshapR_DEMO$dataset_MELBOURNE
#'     
#' tempdir <- basename(tempdir())
#' try(opal_project_create(opal, tempdir))
#' 
#' # push a table in a project.
#' try(
#'   opal_tables_push(
#'   opal,
#'   dataset = dataset,
#'   table_name = 'MELBOURNE',
#'   project_name = tempdir,
#'   .force = TRUE,
#'   .overwrite = TRUE))
#' 
#' }
#'
#' @import dplyr opalr fabR madshapR
#' @importFrom rlang .data
#'
#' @export
opal_tables_push <- function(
    opal,
    dossier = NULL,
    data_dict = NULL,
    dataset = NULL,
    table_name = NULL,
    project_name,
    .force = FALSE,
    .overwrite = FALSE){

  # check on arguments
  if(!is.null(dataset)        & !is.null(dossier))
    stop(call. = FALSE,"Too many argments entered")
  if(!is.null(data_dict)      & !is.null(dossier))
    stop(call. = FALSE,"Too many argments entered")
  if(!is.null(table_name)     & !is.null(dossier))
    stop(call. = FALSE,"Too many argments entered")

  if(is.null(dataset) & is.null(data_dict) & is.null(dossier))
    stop(call. = FALSE,"At least one argument is missing")

  if((!is.null(dataset) | !is.null(data_dict)) & is.null(table_name))
    stop(call. = FALSE,"Table name is missing")
  if(length(table_name) > 1)
    stop(call. = FALSE,"table name must be unique")

  message("Verification of input format.")
  # tests
  if(!is.null(dataset)) 
    as_dataset(dataset,attributes(dataset)$`madshapR::col_id`)
  if(!is.null(dossier))    
    as_dossier(dossier)
  if(!is.null(data_dict))
    data_dict <- as_data_dict_mlstr(data_dict)

  project <- list()
  if(!is.null(dossier)) {
    for(i in names(dossier)){
      # stop()}
      project[[i]]$`dataset`   <- dossier[[i]]
      project[[i]]$`data_dict` <- dossier[[i]] %>% data_dict_extract()
  }}

  if(!is.null(dataset) & !is.null(data_dict)){
    # stop()}
    data_dict_apply(dataset, data_dict)
    project[[table_name]]$`dataset`   <- dataset
    project[[table_name]]$`data_dict` <- data_dict
  }
  if(!is.null(dataset) & is.null(data_dict)){
    # stop()}
    project[[table_name]]$`dataset`   <- dataset
    project[[table_name]]$`data_dict` <- dataset %>% data_dict_extract()
  }
  if(!is.null(data_dict) & is.null(dataset)){
    # stop()}
    project[[table_name]]$`dataset`   <- data_dict %>% data_extract()
    project[[table_name]]$`data_dict` <- data_dict
  }
  
  table_names <- names(project)
  # check if id
  for(i in table_names){
    # stop()}

    # col_id <- attributes(project[[i]][['dataset']])$`madshapR::col_i`
    # if(is.null(col_id))
    #   attributes(project[[i]][['dataset']])$`madshapR::col_i` <-
    #     names(project[[i]][['dataset']][1])
    
    project[[i]][['dataset']] <-
      project[[i]][['dataset']] %>% 
      add_index(name_index = basename(tempfile())) %>% 
      as_tibble()
  }

  message("Verification of input format done.")
  
  # si le project n'existe pas  et que force = TRUE
  if(.force == TRUE){
  if(!opal.project_exists(opal, project_name)){
    opal_project_create(opal, project_name)}}

  if(.overwrite == TRUE){
    warning("Tables overwritten, or specify .overwrite = FALSE")}

  for(i in table_names){
    # stop()}

    if(.force == TRUE){
      if(!opal.table_exists(opal, project_name,i)){
        opal.table_create(
          opal       = opal,
          project    = project_name,
          table      = i)}}

    opal.table_save(
      opal       = opal,
      tibble     = project[[i]][['dataset']],
      project    = project_name,
      table      = i,
      overwrite  = .overwrite,
      force      = .force,
      id.name    = names(project[[i]][['dataset']])[1])

    opal.table_dictionary_update(
      opal       = opal,
      project    = project_name,
      table      = i,
      variables  = project[[i]][['data_dict']][['Variables']],
      categories = project[[i]][['data_dict']][['Categories']])

    message(
      "\nThe table: ",i, 
      " has been successfuly uploaded to Opal in ",project_name)
  }
}

#' @title
#' Download tables from an Opal project as a dossier
#'
#' @description
#' Downloads a dossier or dataset from an Opal environment to the local 
#' environment. This is a wrapper function for[opalr::opal.table_get()] and
#' [opalr::opal.table_dictionary_get()].
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#' [madshapR::as_dossier()] 
#' [madshapR::as_dataset()]
#' [madshapR::as_data_dict_mlstr()]
#'
#' @param opal Opal login attributes.
#' @param project A character string specifying the Opal project name.
#' @param table_list A vector character string specifying Opal tables name.
#' @param content A vector of character string which indicates if the
#' function returns a dataset, or data dictionary. Default is 'dataset'.
#' @param keep_as_dossier whether to return a dossier or a dataset if there is 
#' only one table. TRUE by default, if FALSE returns dataset.
#' @param .remove_id whether to return the id column created in Opal or not. 
#' TRUE by default.
#'
#' @returns
#' Objects (tibbles and list of tibbles) representing tables and their
#' respective data dictionary.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'    
#' # use DEMO_files provided by the package
#' library(madshapR)
#' library(stringr)
#' library(dplyr)
#'
#' dossier <- 
#'   DEMO_files[str_detect(names(DEMO_files),"dataset_MELBOURNE")]
#'
#' tempdir <- basename(tempdir())
#' try(opal_project_create(opal, tempdir))
#' 
#' try(
#'   opal_tables_push(
#'   opal, dossier,project_name = tempdir, .force = TRUE, .overwrite = TRUE))
#'   
#' ###### Example pull a table from a project.
#' try(
#'   glimpse(opal_tables_pull(
#'   opal,project = tempdir,table_list = 'dataset_MELBOURNE_1')))
#' 
#' }
#'
#' @import dplyr opalr fabR madshapR
#' @importFrom rlang .data
#'
#' @export
opal_tables_pull <- function(
    opal,
    project,
    table_list = NULL,
    content = c("dataset","data_dict"),
    keep_as_dossier = TRUE,
    .remove_id = FALSE){

  invisible(opal.execute(opal,"invisible(NULL)"))
  
  if(length(project) > 1 & !is.null(table_list))
    stop(call. = FALSE,"Too many argments entered")
  if(length(project) == 1 & project[1] == "")
    stop(call. = FALSE,"\nYou must provide an Opal project\n")
  if(!is.logical(keep_as_dossier))
    stop(call. = FALSE,
         '`keep_as_dossier` must be TRUE or FALSE (TRUE by default)')
  if(!is.logical(.remove_id))
    stop(call. = FALSE,
         '`.keep_id` must be TRUE or FALSE (TRUE by default)')

  dossier <- list()

  if(is.null(table_list)){
    table_list <- 
      opal.tables(opal = opal,datasource = project) 
    if(nrow(table_list) == 0) 
      stop(call. = FALSE, 'The project has no table.')
    
    table_list <- table_list$`name`
  }

  for(i in table_list){
    # stop()}

    message(
"Download of: ", project ," / ", i,
" (",which(table_list == i),"/",length(table_list), ")")

    # creation of data_dict
    data_dict_i <- 
      silently_run(
      opal.table_dictionary_get(opal = opal, project = project, table = i))

    if(length(data_dict_i) == 0){
      data_dict_i <-
        list(
          project = project,
          table = i,
          variables = tibble(name = as.character()),
          categories =
            tibble(variable = as.character(), name = as.character()))}

    data_dict_i <- 
      data_dict_opalr_fix(data_dict_i) %>%
      as_data_dict_mlstr()

    # creation of dataset
    if("dataset" %in% content == TRUE){
      table_i <- 
        opal.table_get(opal = opal, project = project, table = i)
    }else{table_i <- silently_run(data_extract(data_dict = data_dict_i))}
    
    
    if(ncol(table_i) == 0) table_i <- data_extract(data_dict_i)
    
    # if id is to be removed
    if(.remove_id == TRUE){
      table_i <- select(table_i,-1)
    }else{
    
        # take the Variable part of the dd created with the first column
        data_dict_temp <- data_dict_extract(table_i[1])[[1]]
        
        if(!data_dict_temp$name %in% data_dict_i[['Variables']]$`name`){
          
          data_dict_i[['Variables']] <-
            full_join(
              data_dict_temp,
              data_dict_i[['Variables']],
              by = intersect(
                names(data_dict_temp),names(data_dict_i[['Variables']])))
        }
    }
    
    if(ncol(table_i) == 0) table_i <- data_extract(data_dict_i)

    # only data_dict:
    if("dataset" %in% content == TRUE){
      table_i <- 
        table_i %>%
        dataset_zap_data_dict %>%
        data_dict_apply(data_dict_i) %>% 
        as_dataset(col_id = names(table_i)[1])
    }
    
    dossier_table_i <- list(dataset = table_i, data_dict = data_dict_i)
    dossier_table_i <- list(dossier_table_i)
    names(dossier_table_i) <- i
    
    dossier <- append(dossier, dossier_table_i)
}
  # only data_dict:
  if("dataset" %in% content == FALSE){

    data_dict_list <- 
      dossier %>% lapply(function(x){
        x <- x[['data_dict']]
        return(x)})

    if(length(data_dict_list) == 1 & keep_as_dossier == FALSE)
      data_dict_list <- data_dict_list[[1]]

    return(data_dict_list)}

  # if datasets:
  dataset_list <- 
    dossier %>% lapply(function(x){
      x <- x[['dataset']]
      return(x)}) %>%
    as_dossier()
  
  if(length(dataset_list) == 1 & keep_as_dossier == FALSE)
    dataset_list <- dataset_list[[1]]
  return(dataset_list)
  
  # # # if only one dossier.table
  # # if(length(dossier) == 1) dossier <- dossier[[1]]
  # dossier <- as_dossier(dossier)
  # if(keep_as_dossier == FALSE) dossier <- dossier[[1]]
  # 
  # return(dossier)
}

#' @title
#' Get available taxonomies in format used by Maelstrom Research 
#'
#' @description
#' Downloads all taxonomies from an Opal server in a specific tibble format
#' used in the Maelstrom Research ecosystem.
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#' [madshapR::as_taxonomy()]
#'
#' @param opal Opal login attributes.
#' 
#' @returns
#' A tibble identifying a taxonomy (generally generated from Opal taxonomy.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' library(dplyr)
#' 
#' opal <-
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#' 
#' glimpse(try(taxonomy_opal_mlstr_get(opal)))
#'   
#' }
#'
#' @import dplyr tidyr opalr madshapR
#' @importFrom rlang .data
#'
#' @export
taxonomy_opal_mlstr_get <- function(opal){

  taxonomy <- taxonomy_opal_get(opal)

  taxonomy_unknown <-
    taxonomy %>%
    filter(taxonomy == "Unknown_taxonomy")

  taxonomy_additional <-
    taxonomy %>%
    filter(taxonomy == "Mlstr_additional")

  taxonomy_harmo <-
    taxonomy %>%
    filter(taxonomy == "Mlstr_harmo")

  taxonomy_area <-
    taxonomy %>%
    filter(.data$`taxonomy` == "Mlstr_area") %>%
    mutate(
      vocabulary_short = case_when(
        .data$`vocabulary` == "Sociodemographic_economic_characteristics"~"SDC",
        .data$`vocabulary` == "Lifestyle_behaviours"                     ~"LSB",
        .data$`vocabulary` == "Reproduction"                             ~"REP",
        .data$`vocabulary` == "Health_status_functional_limitations"     ~"HST",
        .data$`vocabulary` == "Diseases"                                 ~"DIS",
        .data$`vocabulary` == "Symptoms_signs"                           ~"SYM",
        .data$`vocabulary` == "Medication_supplements"                   ~"MED",
        .data$`vocabulary` == "Non_pharmacological_interventions"        ~"NPH",
        .data$`vocabulary` == "Health_community_care_utilization"        ~"CAR",
        .data$`vocabulary` == "End_of_life"                              ~"EOL",
        .data$`vocabulary` == "Physical_measures"                        ~"PME",
        .data$`vocabulary` == "Laboratory_measures"                      ~"LAB",
        .data$`vocabulary` == "Cognitive_psychological_measures"         ~"COG",
        .data$`vocabulary` == "Life_events_plans_beliefs"                ~"LIF",
        .data$`vocabulary` == "Preschool_school_work"                    ~"SCH",
        .data$`vocabulary` == "Social_environment"                       ~"SOC",
        .data$`vocabulary` == "Physical_environment"                     ~"PHY",
        .data$`vocabulary` == "Administrative_information"               ~"ADM",
        .data$`vocabulary` == "Mlstr_area_Unknown_vocabulary"            ~"ERR",
        TRUE                                                ~ NA_character_
      )) %>%
    select(
      everything(),-"vocabulary",-"vocabulary_short",-starts_with("term"),
      "vocabulary", "vocabulary_short", starts_with("term"))

  list_of_scales <-
    c("Mlstr_habits",
      "Mlstr_genhealth",
      "Mlstr_cogscale",
      "Mlstr_events",
      "Mlstr_social")

  taxonomy_scales <-
    taxonomy %>%
    filter(.data$`taxonomy` %in% list_of_scales) %>%
    select(
      index_term_scale            = "index_term",
      taxonomy_scale              = "taxonomy",
      taxonomy_scale_title        = "taxonomy_title",
      taxonomy_scale_description  = "taxonomy_description",
      vocabulary_scale            = "vocabulary",
      term_scale                  = "term",
      term_scale_title        = "term_title",
      term_scale_description  = "term_description") %>%
    mutate(
      term = case_when(
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Tobacco"
        ~ "Tobacco",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Alcohol"
        ~ "Alcohol",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Drugs"
        ~ "Drugs",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Nutrition"
        ~ "Nutrition",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Breastfeeding"
        ~ "Breastfeeding",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Physical_activity"
        ~ "Phys_act",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Sleep"
        ~ "Sleep",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Sexual_behaviours"
        ~ "Sex_behav",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Tech_devices"
        ~ "Tech_devices",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Misbehaviour"
        ~ "Misbehav_crim",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Other"
        ~ "Other_lifestyle",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Perception"
        ~ "Perc_health",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Quality"
        ~ "Qual_life",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Development"
        ~ "Life_dev",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Functional"
        ~ "Act_daily_living",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Other"
        ~ "Other",
        .data$`taxonomy_scale` == "Mlstr_cogscale"  &
          .data$`vocabulary_scale` == "Cog_scale"
        ~ "Cognitive_functioning",
        .data$`taxonomy_scale` == "Mlstr_cogscale"  &
          .data$`vocabulary_scale` == "Personality"
        ~ "Personality",
        .data$`taxonomy_scale` == "Mlstr_cogscale"  &
          .data$`vocabulary_scale` == "Emotional"
        ~ "Psychological_emotional_distress",
        .data$`taxonomy_scale` == "Mlstr_cogscale"  &
          .data$`vocabulary_scale` == "Other_psycho"
        ~ "Other_psycholog_measures",
        .data$`taxonomy_scale` == "Mlstr_events"    &
          .data$`vocabulary_scale` == "Life_events"
        ~ "Life_events",
        .data$`taxonomy_scale` == "Mlstr_events"    &
          .data$`vocabulary_scale` == "Beliefs_values"
        ~ "Beliefs_values",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Social_network"
        ~ "Soc_network",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Social_participation"
        ~ "Soc_participation",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Social_support"
        ~ "Soc_support",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Parenting"
        ~ "Parenting",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Other"
        ~ "Other_soc_characteristics",
        .data$`taxonomy_scale` == "Mlstr_habits"    &
          .data$`vocabulary_scale` == "Mlstr_habits_Unknown_vocabulary"

         ~ "Lifestyle_behaviours_Unknown_term",
        .data$`taxonomy_scale` == "Mlstr_genhealth" &
          .data$`vocabulary_scale` == "Mlstr_genhealth_Unknown_vocabulary"

         ~ "Health_status_functional_limitations_Unknown_term",
        .data$`taxonomy_scale` == "Mlstr_cogscale"  &
          .data$`vocabulary_scale` == "Mlstr_cogscale_Unknown_vocabulary"

         ~ "Cognitive_psychological_measures_Unknown_term",
        .data$`taxonomy_scale` == "Mlstr_events"    &
          .data$`vocabulary_scale` == "Mlstr_events_Unknown_vocabulary"

         ~ "Life_events_plans_beliefs_Unknown_term",
        .data$`taxonomy_scale` == "Mlstr_social"    &
          .data$`vocabulary_scale` == "Mlstr_social_Unknown_vocabulary"

         ~ "Social_environment_Unknown_term",
        TRUE
        ~ NA_character_))

  taxonomy_scales <-
    full_join(taxonomy_area, taxonomy_scales, by = "term",multiple = "all")

  taxonomy <-
    taxonomy_unknown %>%
    bind_rows(taxonomy_additional) %>%
    bind_rows(taxonomy_area) %>%
    bind_rows(taxonomy_scales) %>%
    bind_rows(taxonomy_harmo) %>%
    distinct %>%
    mutate(term_scale =
             ifelse(
               .data$`index_term_scale` == 0,
               paste0("[NO_SCALE], ",.data$`term_scale`),
               .data$`term_scale`)) %>%
    separate_rows("term_scale" ,sep = ", ") %>%
    mutate(across(all_of(
      c("index_term_scale","taxonomy_scale","vocabulary_scale","term_scale")),
      ~ ifelse(.data$`term_scale` == "[NO_SCALE]", NA,.))) %>%
    mutate(across(everything(), ~ as.character(.))) %>%
    mutate(across(everything(), ~ na_if(.,""))) %>%
    mutate(across(any_of(
      c('index_taxonomy','index_vocabulary','index_term')),
      ~ as.integer(.))) %>%
    arrange(
      .data$`index_taxonomy`,
      .data$`index_vocabulary`,
      .data$`index_term`) %>%
    mutate(across('index_term_scale',as.integer)) %>%
    mutate(across(
      c('taxonomy_scale', 'vocabulary_scale', 'term_scale'),
      as.character))

  .add_qual_check <- FALSE
  if(.add_qual_check == FALSE) {
    taxonomy <-
      taxonomy %>%
      filter(.data$`index_term` > 0 | is.na(.data$`index_term`)) %>%
      filter(.data$`index_term_scale` > 0 | is.na(.data$`index_term_scale`))}

  taxonomy <- as_taxonomy(taxonomy)

  return(taxonomy)
}

#' @title
#' Get available taxonomies in format used by Opal
#'
#' @description
#' Downloads all taxonomies from an Opal server in a specific tibble format
#' used by Opal.
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#' [madshapR::as_taxonomy()]
#'
#' @param opal Opal login attributes.
#' 
#' @returns
#' A tibble identifying a taxonomy (generally generated from Opal taxonomy).
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' library(dplyr)
#' 
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'   
#' try(glimpse(taxonomy_opal_get(opal)))
#' 
#' }
#'
#' @import dplyr tidyr stringr opalr fabR madshapR
#' @importFrom rlang .data
#'
#' @export
taxonomy_opal_get <- function(opal){

  # get taxons
  taxonomy <- tibble(opal.taxonomies(opal))

  if(nrow(taxonomy) == 0){
    taxonomy <- tibble(
      index_taxonomy = as.integer(),
      index_vocabulary = as.integer(),
      index_term = as.integer(),
      taxonomy = as.character(),
      vocabulary = as.character(),
      taxonomy_title = as.character(),
      taxonomy_description = as.character(),
      term = as.character(),
      label = as.character())

    return(taxonomy)
  }

  taxonomy <-
    taxonomy %>%
    select(taxonomy = 'name',  vocabulary = 'vocabularies', 
           taxonomy_title = 'title', taxonomy_description = 'description') %>%
    add_row(taxonomy = "Unknown_taxonomy",vocabulary = "", .before = TRUE) %>%
    add_index("index_taxonomy", start = 0) %>%
    rowwise() %>%
    mutate(
      vocabulary =
        paste(
          paste0(
            .data$`taxonomy`,
            "_Unknown_vocabulary"),
          .data$`vocabulary`,
          sep = "|"),
      vocabulary = str_remove(.data$`vocabulary`,"\\|$")) %>%
    separate_rows('vocabulary',sep = "\\|") %>%
    group_by(.data$`taxonomy`) %>% 
    add_index("index_vocabulary",start = 0) %>% 
    ungroup() %>%
    rowwise() %>%
    mutate(
      term = ifelse(
        str_detect(
          .data$`vocabulary`,"Unknown_vocabulary"),"",
        toString(
          opal.terms(opal,.data$`taxonomy`, .data$`vocabulary`)$name))) %>%
    tibble() %>%
    mutate(
      term =
        paste(
          paste0(
            .data$`vocabulary`,
            "_Unknown_term"),
          .data$`term`,sep = ", "),
      term = str_remove(.data$`term`,", $")) %>%
    separate_rows('term',sep = ", ") %>%
    group_by(.data$`index_vocabulary`, .data$`index_taxonomy`) %>% 
    add_index("index_term",start = 0) %>% 
    ungroup %>%
    select(
      'index_taxonomy',
      'index_vocabulary',
      'index_term',
      starts_with('taxonomy'),
      everything())

  .add_qual_check <- FALSE
  if(.add_qual_check == FALSE)
    taxonomy <- taxonomy %>% filter(.data$`index_term` != 0)
  
  terms_labels <- 
    tibble(term = as.character(),
           term_title = as.character(),
           term_description = as.character())
  
  distinct_vocabularies <- distinct(taxonomy[c('taxonomy','vocabulary')])
  
  for(i in seq_len(nrow(distinct_vocabularies))){
    # stop()}
    
    message(i,'/',nrow(distinct_vocabularies),
            " - Gather taxonomy of ",distinct_vocabularies$vocabulary[i])
    terms_labels <- 
      bind_rows(
        terms_labels,
        tibble(
          opal.terms(
            opal,
            distinct_vocabularies$taxonomy[i],
            distinct_vocabularies$vocabulary[i])) %>%
          select(term = 'name',
                 term_title = 'title',
                 term_description = 'description') %>%
          mutate(taxonomy = distinct_vocabularies$taxonomy[i],
                 vocabulary = distinct_vocabularies$vocabulary[i]))
  }
  

  if(nrow(terms_labels) != nrow(taxonomy)){
    stop(call. = FALSE, "Problem in taxonomy. Please contact us.")}
  
  taxonomy <- 
    taxonomy %>%
    full_join(terms_labels,by = c('taxonomy', 'vocabulary', 'term')) %>%
    as_taxonomy() 

  return(taxonomy)

}

#' @title
#' Transform a data dictionary object from 'opalr' format to Opal format
#'
#' @description
#' Transforms a data dictionary from 'opalr' format to Opal format.
#' A data dictionary imported using the 'opalr' package has a different 
#' structure and will be transformed to the structure used in Maelstrom 
#' packages.
#'
#' @details
#' Opal is the OBiBa application for data management, and Opal environments can 
#' be integrated with RStudio environments using the package `opalr`. 
#' The user must have adequate credentials to interact with a specific Opal 
#' environment. Some function errors produced may be associated with the 
#' handler or Opal read/write permissions.
#'
#' @seealso
#' Please see [Opal documentation](https://opaldoc.obiba.org/) for 
#' complete documentation.
#' [madshapR::as_data_dict_mlstr()]
#'
#' @param data_dict A list of tibble(s) representing metadata to be
#' transformed. Automatically generated if not provided.
#'
#' @returns
#' A list of tibble(s) identifying a data dictionary.
#'
#' @examples
#' \dontrun{
#' 
#' library(opalr)
#' opal <- 
#'  opal.login('administrator','password',
#'    url ='https://opal-demo.obiba.org/')
#'    
#' # use DEMO_files provided by the package
#' library(madshapR)
#' library(stringr)
#' library(dplyr)
#' 
#' dossier <-
#'   DEMO_files[str_detect(names(DEMO_files),"dataset_MELBOURNE")]
#' 
#' tempdir <- basename(tempdir())
#' try(opal_project_create(opal, tempdir))
#' 
#' try(
#'   opal_tables_push(
#'   opal, dossier,project_name = tempdir, .force = TRUE, .overwrite = TRUE))
#' 
#' # get the data dictionary and reshape it.
#'  data_dict <-
#'    try(
#'    opal.table_dictionary_get(
#'    opal,project = tempdir,table = "dataset_MELBOURNE"))
#' 
#'  data_dict <- try(data_dict_opalr_fix(data_dict))
#'  glimpse(data_dict)
#'   
#' }
#'
#' @import dplyr tidyr
#' @importFrom rlang .data
#'
#' @export
data_dict_opalr_fix <- function(data_dict){

  # test if actually an opalr data dictionary
  if(sum(names(data_dict) %in% c("variables", "table", "project")) != 3){
    stop(call. = FALSE,
"Your file is not in the opalr format. Please provide another file")}

  data_dict[['Variables']]  <-
    data_dict[['variables']] %>% as_tibble() %>%
    mutate(across(everything(), ~ as.character(.))) %>%
    mutate(across(everything(), ~ na_if(.,"")))

  if(sum(nrow(data_dict[['categories']])) > 0){
    data_dict[['Categories']] <-
      data_dict[['categories']] %>% as_tibble() %>%
      mutate(across(everything(), ~ as.character(.))) %>%
      mutate(across(everything(), ~ na_if(.,"")))
  }

  data_dict[['variables']]  <- NULL
  data_dict[['categories']] <- NULL

  return(data_dict)
}
