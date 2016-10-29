'use babel';

import {
    CompositeDisposable,
    Directory,
    File
} from 'atom';
import {
    QspFilesView
} from './qsp-files-view'

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
        let files = this.findQspFiles();
        let view = new QspFilesView();
        view.initialize(files)
    },

    findQspFiles(directory) {
        let found = [];

        if (!directory) {
            let directories = atom.project.getDirectories();
            for (var i = 0; i < directories.length; i++) {
                found = found.concat(this.findQspFiles(directories[i]));
            }
        } else {
            let entries = directory.getEntriesSync();
            for (var i = 0; i < entries.length; i++) {

                if ((entries[i] instanceof File) && (entries[i].getPath().slice((entries[i].getPath().lastIndexOf('.') - 1 >>> 0) + 2) === 'qsp')) {
                    found.push(entries[i]);
                }

                if (entries[i] instanceof Directory) {
                    found = found.concat(this.findQspFiles(entries[i]));
                }
            }
        }

        return found;
    }

};
