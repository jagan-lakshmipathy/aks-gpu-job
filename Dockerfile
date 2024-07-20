FROM python:3.11-slim

RUN mkdir /opt/pytorch-demo
COPY  mnist.py /opt/pytorch-demo
COPY requirements.txt /opt/pytorch-demo

WORKDIR /opt/pytorch-demo

# Add folder for the logs.
RUN pip install --prefer-binary --no-cache-dir torch==2.2.1 torchvision==0.17.1 numpy==1.26.4
RUN pip install --prefer-binary --no-cache-dir -r requirements.txt

RUN chgrp -R 0 /opt/pytorch-demo \
  && chmod -R g+rwX /opt/pytorch-demo

ENTRYPOINT ["python3", "/opt/pytorch-demo/mnist.py"]
