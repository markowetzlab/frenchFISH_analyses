import glob
import pandas as pd

path_to_dir = "~" # change to be path to frenchFISH_analyses directory
images = glob.glob(path_to_dir+"/frenchFISH_analyses/image_processing/input_data/*/*")
images = ["/ftp/ciluser/Adam_Cambridge/"+"/".join(image.split("/")[-2:]) for image in images]
images.sort()

# make columns of spreadsheet
description = []
technical_details = []
ncbi_organism_classification = []
cell_type = []
cellular_component = []
biological_process = []
image_mode = []
visualization_methods = []
attribution_names = []
attribution_link = []

for image in images:
    image_name = image.split("/")[-1]
    patient = image.split("/")[-2]

    if image_name[-3:] == "jpg":
        x = image_name.split("_x=")[-1][0]
        y = image_name.split("_y=")[-1][0]
        if image_name[-5] == "1":
            if patient[:2] == "SC":
                description.append("1st channel of image "+image_name.split("image_")[-1][0]+" from "+patient)
            else:
                description.append("1st channel of tile x="+x+", y="+y+" from "+patient)
            cellular_component.append("All DNA")
            biological_process.append("All DNA determined by DAPI stain")
        elif image_name[-5] == "2":
            if patient[:2] == "SC":
                description.append("2nd channel of image "+image_name.split("image_")[-1][0]+" from "+patient)
            else:
                description.append("2nd channel of tile x="+x+", y="+y+" from "+patient)
            cellular_component.append("hTERT, c-MYC, and SE7 gene regions")
            biological_process.append("Copy number of hTERT, c-MYC, and SE7 determined by colored probes")
        elif image_name[-5] == "3":
            if patient[:2] == "SC":
                description.append("3rd channel of image "+image_name.split("image_")[-1][0]+" from "+patient)
            else:
                description.append("3rd channel of tile x="+x+", y="+y+" from "+patient)
            cellular_component.append("hTERT, c-MYC, and SE7 gene regions")
            biological_process.append("Copy number of hTERT, c-MYC, and SE7 determined by colored probes")
        elif image_name[-5] == "4":
            if patient[:2] == "SC":
                description.append("4th channel of image "+image_name.split("image_")[-1][0]+" from "+patient)
            else:
                description.append("4th channel of tile x="+x+", y="+y+" from "+patient)
            cellular_component.append("hTERT, c-MYC, and SE7 gene regions")
            biological_process.append("Copy number of hTERT, c-MYC, and SE7 determined by colored probes")
        else:
            if patient[:2] == "SC":
                description.append("Combined channels of image "+image_name.split("image_")[-1][0]+" from "+patient)
            else:
                description.append("Combined channels of tile x="+x+", y="+y+" from "+patient)
            cellular_component.append("Gene regions as well as all DNA")
            biological_process.append("All DNA determined by DAPI stain as well as colored probes to determine the copy number of hTERT, c-MYC, and SE7")
        technical_details.append("Max projection of 10 layers around most in focus layer of corresponding TIFF z-stack")

    else:
        x = image_name.split("_x")[-1][:3].lstrip("0")
        y = image_name.split("_y")[-1][:3].lstrip("0")
        z = image_name.split("_z")[-1][:3].lstrip("0")
        if patient[:2] == "SC":
            description.append("Image "+image_name.split("z")[0].split("_1")[-1].lstrip("0")+", z="+image_name.split("z")[-1].split(".")[0].lstrip("0")+" from "+patient)
            technical_details.append("One z layer of a z-stack at the given image")
        else:
            description.append("Tile x="+x+", y="+y+", z="+z+" from "+patient)
            technical_details.append("One z layer of a z-stack at the given tile position")
        cellular_component.append("hTERT, c-MYC, and SE7 gene regions")
        biological_process.append("Copy number of hTERT, c-MYC, and SE7 determined by colored probes")


    ncbi_organism_classification.append("Homo sapiens")
    cell_type.append("High-grade serious overian cancer")
    image_mode.append("Fluorescence in situ hybridization (FISH)")
    visualization_methods.append("Nikon Eclipse fluorescence inverted microscope equipped with a charge-coupled device camera (Andor Neo sCMOS), using filter sets for DAPI/ YGFP/TRITC/CY GFP with an objective lens (Plan Apo VC 100x, Nikon). Captured with 100x magnification of the objective and a pixel size of 0.07 microns")
    attribution_names.append("Cancer Research UK Cambridge Institute")
    attribution_link.append("https://www.cruk.cam.ac.uk/")


# Generate dataframe from list and write to xlsx.
pd.DataFrame(list(zip(images, description, technical_details, ncbi_organism_classification, cell_type, cellular_component, biological_process, image_mode, visualization_methods, attribution_names, attribution_link)),
    columns = ["File name", "Description", "Technical Details", "NCBI Organism Classification", "Cell Type", "Cellular Component", "Biological Process", "Image Mode", "Visualization Methods", "Attribution: Names", "Attribution:Link"]).to_excel('CIL_frenchfish.xlsx', header=True, index=False)



#images_per_patient = {}
#for image in images:
#    patient = image.split("/")[-2]
#    if patient not in images_per_patient:
#        images_per_patient[patient] = 1
#    else:
#        images_per_patient[patient] = images_per_patient[patient] + 1


#print(images)
#print(len(images))
#print(images_per_patient)
