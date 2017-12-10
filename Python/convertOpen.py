import coremltools

proto_file = 'pose_deploy_linevec.prototxt'
caffe_model = 'pose_iter_160000.caffemodel'

coreml_model = coremltools.converters.caffe.convert((caffe_model, proto_file), image_input_names='image', image_scale=1/255.)

coreml_model.save('openpose100.mlmodel')