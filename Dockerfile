FROM python:3.11-slim

RUN mkdir /opt/pytorch-rephrase-azure
RUN mkdir /opt/pytorch-rephrase-azure/data
COPY  mnist.py /opt/pytorch-rephrase-azure
COPY .env /opt/pytorch-rephrase-azure

WORKDIR /opt/pytorch-rephrase-azure

# Add folder for the logs.
RUN pip install --prefer-binary --no-cache-dir torch torchtext
RUN pip install tensorboardX
RUN pip install spacy
RUN python -m spacy download en_core_web_sm
RUN pip install python-dotenv
RUN pip install azure-identity
RUN pip install azure-storage==0.36.0
RUN pip install azure-storage-blob

RUN chgrp -R 0 /opt/pytorch-rephrase-azure \
  && chmod -R g+rwX /opt/pytorch-rephrase-azure

ENTRYPOINT ["python3", "/opt/pytorch-rephrase-azure/rephrase_azure.py"]
