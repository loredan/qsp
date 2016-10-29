'use babel';

import { CompositeDisposable } from 'atom';

export default {

  subscriptions: null,

  activate(state) {
    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'qsp:toggle': () => this.toggle(),
      'qsp:decode': () => this.decode()
    }));
  },

  deactivate() {
    this.subscriptions.dispose();
  },

  toggle() {
    console.log('Qsp was toggled!');
  },

  decode() {
    var options = this.findQspFiles();
  },

  findQspFiles(var directory) {
    found = []

    if (!directory) {
      for (var path in atom.project.getPaths()) {
        found.concat(findQspFiles(directory(path)));
      }
    } else {
      for (var object in directory.getEntriesSync()) {
        if (object instanceof File && object.getPath().slice((object.getPath().lastIndexOf('.') - 1 >>> 0) + 2) === 'qsp') {
          found.push(object.getPath());
        }

        if (object instanceof Directory) {
          found.concat(findQspFiles(object));
        }
      }
    }

    return found;
  }

};
