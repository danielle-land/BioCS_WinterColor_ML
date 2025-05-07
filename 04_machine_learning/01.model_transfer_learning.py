import os
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping

# Set base directories
base_dir = '/kuhpc/work/bi/d135l135/WinterColor_ML/04_machine_learning'
train_dir = os.path.join(base_dir, 'train')
val_dir = os.path.join(base_dir, 'val')
test_dir = os.path.join(base_dir, 'test')
output_model = os.path.join(base_dir, 'coat_color_model.h5')

# Parameters
IMG_SIZE = (256, 256) # resize images
BATCH_SIZE = 32 # 32 images per batch
EPOCHS = 20

# Rescale images
train_gen = ImageDataGenerator(rescale=1./255, horizontal_flip=True, rotation_range=15) # augment training data
val_gen = ImageDataGenerator(rescale=1./255)
test_gen = ImageDataGenerator(rescale=1./255)

train_data = train_gen.flow_from_directory(train_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
val_data = val_gen.flow_from_directory(val_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')
test_data = test_gen.flow_from_directory(test_dir, target_size=IMG_SIZE, batch_size=BATCH_SIZE, class_mode='categorical')

# Model definition
# Uses MobileNetV2 PRETRAINED on ImageNet as base
# Remove original classification head
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(256, 256, 3)) 
x = base_model.output
x = GlobalAveragePooling2D()(x) # Global average pooling to flatten outout
x = Dense(128, activation='relu')(x) # Loss function
predictions = Dense(train_data.num_classes, activation='softmax')(x) # softmax layer to match num of classes

model = Model(inputs=base_model.input, outputs=predictions) # define the model

# Freeze base model (so only new ones are trained)
# Speed up training and prevent overfitting
for layer in base_model.layers:
    layer.trainable = False

# Compile
# Adam optimizer
# Categorical cross entropy loss
# Track the model accuracy
model.compile(optimizer=Adam(learning_rate=1e-4), loss='categorical_crossentropy', metrics=['accuracy'])

# Callbacks
# Save best model based on loss
checkpoint = ModelCheckpoint(output_model, monitor='val_loss', save_best_only=True, verbose=1)
# Stop modeling if it does not improve for 5 epochs
early_stop = EarlyStopping(monitor='val_loss', patience=5, verbose=1)

# Train
# Trains with training dataset and monitors performace with validation set
model.fit(train_data, validation_data=val_data, epochs=EPOCHS, callbacks=[checkpoint, early_stop])

# Evaluate
# Model evauated on the test set and prints the accuracy
loss, acc = model.evaluate(test_data)
print(f"\nFinal Test Accuracy: {acc:.4f}")

