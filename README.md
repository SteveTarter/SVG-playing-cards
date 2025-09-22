# SVG playing cards

Tools to make a wide selection of playing cards in SVG format.

# Cloning the repository

This repo counts on submodule projects.  In order to get all of these dependent components, clone the repository with the following command:

```
git clone --recurse-submodules https://github.com/SteveTarter/SVG-playing-cards.git
```

# Common usage patterns

Currently, the --help output is not very helpful.  Until this is addressed, here's a couple of examples.  To generate a full deck of cards to a folder:

```
mkdir -p out
./makecards \
  --dir=out \
  --poker \
  --back=Diamond \
  --jokers=2 --backs=1 \
  --ace=Fancy --ace1="cards.rev.uk" --ace2="cards.rev.uk" \
  --qr="HTTPS://CARDS.REVK.UK/"
```

To generate a single card to stdout:
```
./makecards \
  --inline \
  --poker \
  --card=AS \
  --back=Diamond \
  --ace=Fancy --ace1="cards.rev.uk" --ace2="cards.rev.uk" \
  --qr="HTTPS://CARDS.REVK.UK/" > ace_of_spades.svg
```

# Create ML training dataset

Since makecards is capable of generating cards in multiple permutaions, it seemed perfect to augment the dataset used in the [Playing Card Classifier](https://github.com/SteveTarter/playing-card-classifier) project.  This script currently adds 32 new versions of each of the 52 standard cards.  The existing dataset includes 120 examples of each card, so these additions should have a positive effect on the model.  The command is written in bash shell, and can be started by executing the following:
```
bash make_card_dataset.sh
```

Once these cards have been generated, they can be woven into the dataset using shell commands.  Once the dataset has been downloaded and expanded to /tmp/cards in the Playing Card Classifier [Jupyter notebook](https://github.com/SteveTarter/playing-card-classifier/blob/main/model/Playing%20Card%20Classifier%20ML%20Model.ipynb), copy the generated data using the following commands:
```
find . -type f | awk '{name=substr($0,3); printf "cp -p \"%s\" \"/tmp/cards/train/%s\"\n", name, name}' | /bin/bash -x
```

Unfortunately, this does nothing to help the joker situation.  Jokers are the most variable cards in a standard deck, presenting a unique challenge for recognition tasks. While face and number cards adhere to a strict visual standard, joker designs range wildly, from simple illustrations that mimic traditional court cards to intricate, standalone works of art. This high degree of artistic variance and lack of a consistent pattern make it exceptionally difficult to train a machine learning model to reliably identify them.
