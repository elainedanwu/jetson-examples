#!/bin/bash

echo "run example：$1"
BASE_PATH=/tmp/reComputer
echo "----example init----"
mkdir -p $BASE_PATH/
JETSON_REPO_PATH="$BASE_PATH/jetson-containers"
if [ -d $JETSON_REPO_PATH ]; then
    echo "jetson-ai-lab exists."
else
    echo "jetson-ai-lab does not installed. start init..."
    cd $BASE_PATH/
    git clone --depth=1 https://github.com/dusty-nv/jetson-containers
    cd $JETSON_REPO_PATH
    sudo apt update; sudo apt install -y python3-pip
    pip3 install -r requirements.txt
fi
echo "----example start----"
cd $JETSON_REPO_PATH
case "$1" in
    "llava")
        ./run.sh $(./autotag llava) \
        python3 -m llava.serve.cli \
        --model-path liuhaotian/llava-v1.5-7b \
        --image-file /data/images/hoover.jpg
    ;;
    "llava-v1.5-7b")
        ./run.sh $(./autotag llava) \
        python3 -m llava.serve.cli \
        --model-path liuhaotian/llava-v1.5-7b \
        --image-file /data/images/hoover.jpg
    ;;
    "llava-v1.6-vicuna-7b")
        ./run.sh $(./autotag local_llm) \
        python3 -m local_llm --api=mlc \
        --model liuhaotian/llava-v1.6-vicuna-7b \
        --max-context-len 768 \
        --max-new-tokens 128
    ;;
    "Sheared-LLaMA-2.7B-ShareGPT")
        ./run.sh $(./autotag local_llm) \
        python3 -m local_llm.chat --api=mlc \
        --model princeton-nlp/Sheared-LLaMA-2.7B-ShareGPT
    ;;
    "text-generation-webui")
        # download llm model
        ./run.sh --workdir=/opt/text-generation-webui $(./autotag text-generation-webui) /bin/bash -c \
        'python3 download-model.py --output=/data/models/text-generation-webui TheBloke/Llama-2-7b-Chat-GPTQ'
        # run text-generation-webui
        ./run.sh $(./autotag text-generation-webui)
    ;;
    "stable-diffusion-webui")
        ./run.sh $(./autotag stable-diffusion-webui)
    ;;
    "nanoowl")
        ./run.sh $(./autotag nanoowl) bash -c "ls /dev/video* && cd examples/tree_demo && python3 tree_demo.py ../../data/owl_image_encoder_patch32.engine"
    ;;
    "whisper")
        ./run.sh $(./autotag whisper)
    ;;
    "nanodb")
        # check data files
        DATA_PATH="$BASE_PATH/data/datasets/coco/2017"
        if [ ! -d $DATA_PATH ]; then
            mkdir -p $DATA_PATH
            cd $DATA_PATH
            wget http://images.cocodataset.org/zips/train2017.zip
            wget http://images.cocodataset.org/zips/val2017.zip
            wget http://images.cocodataset.org/zips/unlabeled2017.zip
            unzip train2017.zip
            unzip val2017.zip
            unzip unlabeled2017.zip
        fi
        
        # check index files
        INDEX_PATH="$BASE_PATH/data/nanodb_coco_2017"
        if [ ! -d $INDEX_PATH ]; then
            cd $BASE_PATH/data/
            wget https://nvidia.box.com/shared/static/icw8qhgioyj4qsk832r4nj2p9olsxoci.gz -O nanodb_coco_2017.tar.gz
            tar -xzvf nanodb_coco_2017.tar.gz
        fi
        
        # RUN
        cd $JETSON_REPO_PATH
        ./run.sh $(./autotag nanodb) \
        python3 -m nanodb \
        --path /data/nanodb/coco/2017 \
        --server --port=7860
    ;;
    *)
        echo "Unknown example"
        # handle unknown
    ;;
esac
echo "----example done----"
