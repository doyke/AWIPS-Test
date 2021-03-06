/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.uf.viz.spellchecker.dialogs;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Deque;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.jdt.ui.PreferenceConstants;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector;
import org.eclipse.ui.texteditor.spelling.SpellingProblem;

import com.raytheon.uf.common.localization.IPathManager;
import com.raytheon.uf.common.localization.LocalizationContext;
import com.raytheon.uf.common.localization.LocalizationContext.LocalizationLevel;
import com.raytheon.uf.common.localization.LocalizationContext.LocalizationType;
import com.raytheon.uf.common.localization.LocalizationFile;
import com.raytheon.uf.common.localization.PathManagerFactory;
import com.raytheon.uf.common.localization.exception.LocalizationException;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.common.util.FileUtil;
import com.raytheon.uf.viz.spellchecker.Activator;
import com.raytheon.uf.viz.spellchecker.jobs.SpellCheckJob;

/**
 * Display the Spell Checker dialog.
 * 
 * <pre>
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * 18 APR 2008  ###        lvenable    Initial creation
 * 01Mar2010    4765       MW Fegan    Moved from GFE plug-in.
 * 09/24/2014   #16693     lshi        filter out swear words in spelling check
 * 10/30/2014   #16693     lshi        Add more swear words to the filter
 * 
 * </pre>
 * 
 * @author lvenable
 * @version 1.0
 * 
 */
public class SpellCheckDlg extends Dialog implements ISpellingProblemCollector {
	private static java.util.List<String> swearWords = Arrays.asList("ASSHOLE", "ASSHOLE'S", "ASSHOLES",
			"BITCH", "BITCH'S", "BITCHES", "LEPROSY", "GAYEST",
			"SHIT", "PISS", "PISSED","PISSER","PISSES","PISSING","TITS");

    private static final transient IUFStatusHandler statusHandler = UFStatus.getHandler(SpellCheckDlg.class);

    private static final Pattern DIGITS = Pattern.compile("\\d");

    /**
     * The event handler for the check word button. It doubles as the problem
     * collector for its internal SpellCheckJob.
     * 
     * @author wldougher
     */
    class CheckWord extends SelectionAdapter implements
            ISpellingProblemCollector {

        private SpellCheckJob wordCheckJob;

        private SpellingProblem wordProblem;

        /*
         * If there's a spelling problem with the replacement word, save the
         * fact that it was wrong and jump to the end.
         * 
         * @see
         * org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector#accept
         * (org.eclipse.ui.texteditor.spelling.SpellingProblem)
         */
        @Override
        public void accept(SpellingProblem problem) {
            wordProblem = problem;
            endCollecting();
        }

        /*
         * 
         * @seeorg.eclipse.ui.texteditor.spelling.ISpellingProblemCollector#
         * beginCollecting()
         */
        @Override
        public void beginCollecting() {
            wordProblem = null;
        }

        /**
         * Tell the user if the replacement word is spelled correctly or not.
         * 
         * @seeorg.eclipse.ui.texteditor.spelling.ISpellingProblemCollector# 
         *                                                                   endCollecting
         *                                                                   ()
         */
        @Override
        public void endCollecting() {
            if (wordProblem == null) {
                wordCheckLbl.setText("The word is correct");
            } else {
                wordCheckLbl.setText(wordProblem.getMessage());
            }
        }

        /**
         * The action taken when the check word button is clicked.
         */
        @Override
        public void widgetSelected(SelectionEvent evt) {
            wordCheckJob = new SpellCheckJob("wordCheck");
            wordCheckJob.setCollector(this);
            wordCheckJob.setText(replaceWithTF.getText());
            wordCheckJob.schedule();
        }
    }

    /**
     * A pattern to recognize "add to dictionary" proposals
     */
    public static final Pattern ADD_TO = Pattern
            .compile("Add '(.*)' to dictionary");

    /**
     * A pattern to recognize "change to" proposals
     */
    public static final Pattern CHANGE_TO = Pattern.compile("Change to '(.*)'");

    /**
     * The encoding of the user dictionary file
     */
    private static final String DICTIONARY_ENCODING = "US-ASCII";

    private static final StyleRange REDSTYLE = new StyleRange(0, 0, Display
            .getDefault().getSystemColor(SWT.COLOR_WHITE), Display.getDefault()
            .getSystemColor(SWT.COLOR_RED));

    /**
     * The simple name of the user spelling dictionary file
     */
    private static final String SPELLDICT = "spelldict";

    private Button addWordBtn;

    private ICompletionProposal addWordProposal;

    private Button checkWordBtn;

    /**
     * The display control.
     */
    private Display display;

    private Set<String> ignoreAll;

    private Button ignoreAllBtn;

    private Button ignoreBtn;

    /**
     * Misspelled word label.
     */
    private Label misspelledLbl;

    private boolean mixedToRestore;

    private boolean mixedWasDefault;

    private SpellingProblem problem;

    private Button replaceAllBtn;

    private Button replaceBtn;

    /**
     * Replace with text control.
     */
    private Text replaceWithTF;

    /**
     * Return object when the shell is disposed.
     */
    private String returnObj = null;

    /**
     * Dialog shell.
     */
    private Shell shell;

    private SpellCheckJob spellCheckJob;

    /**
     * The styled text of the product editor.
     */
    private StyledText styledText;

    /**
     * Suggestion list control.
     */
    private List suggestionList;

    private boolean upperToRestore;

    private boolean upperWasDefault;

    private String userDEncodingToRestore;

    private boolean userDEncodingWasDefault;

    private LocalizationFile userDLFile;

    private String userDToRestore;

    private boolean userDWasDefault;

    private Label wordCheckLbl;

    private String category = "WORKSTATION";

    private String source = "SPELL_CHECKER";

    private boolean sentenceWasDefault;

    private boolean sentenceToRestore;

    private boolean digitsWasDefault;

    private boolean digitsToRestore;

    private boolean nonLettersWasDefault;

    private boolean nonLettersToRestore;

    private boolean singleLettersWasDefault;

    private boolean singleLettersToRestore;

    /**
     * Constructor.
     * 
     * @param parent
     *            Parent shell.
     * @param styledTest
     *            control containing the text to spell check
     */
    public SpellCheckDlg(Shell parent, StyledText styledText) {
        super(parent, SWT.NONE);
        this.styledText = styledText;
        init();
    }

    /**
     * Constructor. This version allows the client to pass in the category and
     * source used for message posting.
     * 
     * @param parent
     *            the parent shell
     * @param styledText
     *            control containing the text to spell check
     * @param category
     *            Alert VIZ category
     * @param source
     *            Alert VIZ source
     */
    public SpellCheckDlg(Shell parent, StyledText styledText, String category,
            String source) {
        super(parent, SWT.NONE);
        this.styledText = styledText;
        this.category = category;
        this.source = source;
        init();
    }

    /**
     * Initializes data structures used for the spell checking.
     */
    private void init() {
        ignoreAll = new HashSet<String>();
        spellCheckJob = new SpellCheckJob("spellCheck");
        spellCheckJob.setText(styledText.getText());
        spellCheckJob.setCollector(this);
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector#accept(org
     * .eclipse.ui.texteditor.spelling.SpellingProblem)
     */
    public void accept(SpellingProblem problem) {
        if (shell.isDisposed()) {
            return;
        }

        this.problem = problem;
        addWordProposal = null;

        styledText.setSelectionRange(problem.getOffset(), problem.getLength());
        styledText.showSelection();
        String badWord = styledText.getSelectionText();
        misspelledLbl.setText(badWord);

        ICompletionProposal[] proposals = problem.getProposals();
        if (proposals != null && proposals.length > 0) {
            for (ICompletionProposal proposal : proposals) {
                String pdString = proposal.getDisplayString();
                Matcher pdMatch = CHANGE_TO.matcher(pdString);
                if (pdMatch.matches()) {
                    String replString = pdMatch.group(1).toUpperCase();
                    // proposals may include case changes, which get lost
                    //if (replString != badWord) { 
                    if (!swearWords.contains(replString) && !replString.equals(badWord)) {
                        suggestionList.add(replString);
                    }
                }
                Matcher addMatch = ADD_TO.matcher(pdString);
                if (addMatch.matches()) {
                    addWordProposal = proposal;
                }
            }
            if (suggestionList.getItemCount() > 0) {
                suggestionList.select(0);
                replaceWithTF.setText(suggestionList.getItem(0));
            }
        }

        StyleRange styleRange = styledText.getStyleRangeAtOffset(problem
                .getOffset());
        if (styleRange == null || styleRange.isUnstyled()
                || styleRange.similarTo(REDSTYLE)) {
            if (ignoreAll.contains(badWord)) {
                scanForErrors();
            } else {
                replaceBtn.setEnabled(true);
                ignoreBtn.setEnabled(true);
                if (addWordProposal != null) {
                    addWordBtn.setEnabled(true);
                }
                replaceAllBtn.setEnabled(true);
                ignoreAllBtn.setEnabled(true);
                checkWordBtn.setEnabled(true);
            }
        } else { // skip locked text ranges
            scanForErrors();
        }

        // Skip "misspellings" that contain numbers. I use Matcher here because
        // for some reason, Eclipse's spell checker API's preference for this
        // does absolutely nothing.
        // TODO: Remove this code when Eclipse spell checking properly respects
        // PreferenceConstants.SPELLING_IGNORE_DIGITS
        Matcher containsDigits = DIGITS.matcher(badWord);
        if (containsDigits.find()) {
            scanForErrors();
        }

    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector#beginCollecting
     * ()
     */
    public void beginCollecting() {
        // nothing at present
    }

    /**
     * Create the Close button.
     */
    private void createCloseButton() {
        GridData gd = new GridData(SWT.CENTER, SWT.DEFAULT, true, false);
        Composite buttonComp = new Composite(shell, SWT.NONE);
        buttonComp.setLayoutData(gd);
        buttonComp.setLayout(new GridLayout(4, false));

        gd = new GridData(120, SWT.DEFAULT);
        Button closeBtn = new Button(buttonComp, SWT.PUSH);
        closeBtn.setText("Close");
        closeBtn.setLayoutData(gd);
        closeBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                shell.dispose();
            }
        });
    }

    /**
     * Create the main controls.
     */
    private void createMainControls() {
        Composite mainComp = new Composite(shell, SWT.NONE);
        mainComp.setLayoutData(new GridData(SWT.FILL, SWT.DEFAULT, true, false));
        mainComp.setLayout(new GridLayout(1, false));

        createTopControls(mainComp);

        createMiddleControls(mainComp);
    }

    /**
     * Create the controls on the middle of the display.
     * 
     * @param mainComp
     *            Parent composite.
     */
    private void createMiddleControls(Composite mainComp) {
        Composite middleComp = new Composite(mainComp, SWT.NONE);
        middleComp.setLayoutData(new GridData(SWT.FILL, SWT.DEFAULT, true,
                false));
        middleComp.setLayout(new GridLayout(3, false));

        GridData gd = new GridData(SWT.FILL, SWT.DEFAULT, true, false);
        gd.horizontalSpan = 3;
        Label suggestionsLbl = new Label(middleComp, SWT.NONE);
        suggestionsLbl.setText("Suggestions:");
        suggestionsLbl.setLayoutData(gd);

        gd = new GridData(SWT.FILL, SWT.FILL, true, true);
        gd.verticalSpan = 4;
        gd.heightHint = 250;
        gd.widthHint = 200;
        suggestionList = new List(middleComp, SWT.BORDER | SWT.SINGLE
                | SWT.V_SCROLL);
        suggestionList.setLayoutData(gd);
        suggestionList.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                replaceWithTF.setText(suggestionList.getItem(suggestionList
                        .getSelectionIndex()));
            }
        });

        gd = new GridData(120, SWT.DEFAULT);
        replaceBtn = new Button(middleComp, SWT.PUSH);
        replaceBtn.setText("Replace");
        replaceBtn.setLayoutData(gd);
        replaceBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                int problemOffset = problem.getOffset();
                String replaceText = replaceWithTF.getText();
                styledText.replaceTextRange(problemOffset, problem.getLength(),
                        replaceText);
                spellCheckJob.setText(styledText.getText());
                spellCheckJob.setOffset(problemOffset + replaceText.length());
                scanForErrors();
            }
        });

        gd = new GridData(120, SWT.DEFAULT);
        ignoreBtn = new Button(middleComp, SWT.PUSH);
        ignoreBtn.setText("Ignore");
        ignoreBtn.setLayoutData(gd);
        ignoreBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                scanForErrors();
            }
        });

        gd = new GridData(120, SWT.DEFAULT);
        replaceAllBtn = new Button(middleComp, SWT.PUSH);
        replaceAllBtn.setText("Replace All");
        replaceAllBtn.setLayoutData(gd);
        replaceAllBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                final int problemOffset = problem.getOffset();
                final String oldText = misspelledLbl.getText();
                final int oldTextLen = oldText.length();
                // Set up a "whole word only" search
                Pattern pattern = Pattern.compile("(\\b)("
                        + Pattern.quote(oldText) + ")(\\b)");
                String fullText = styledText.getText();
                Matcher matcher = pattern.matcher(fullText);

                // Build a replacement list in reverse order
                int probStart;
                StyleRange styleRange;
                Deque<Integer> repList = new LinkedList<Integer>();
                boolean found = matcher.find(problemOffset);
                do {
                    probStart = matcher.start(2);
                    // Only replace unstyled (unlocked) instances
                    styleRange = styledText.getStyleRangeAtOffset(probStart);
                    if (styleRange == null || styleRange.isUnstyled()) {
                        repList.addFirst(Integer.valueOf(probStart));
                    }
                    found = matcher.find();
                } while (found);
                String newText = replaceWithTF.getText();

                // Iterate through the replacement list.
                // Working backwards avoids a tedious offset-adjust step.
                for (int replacePt : repList) {
                    styledText.replaceTextRange(replacePt, oldTextLen, newText);
                }

                // Set up to scan just after the first (by offset) replacement
                spellCheckJob.setText(styledText.getText());
                spellCheckJob.setOffset(problemOffset + newText.length());
                scanForErrors();
            }
        });

        gd = new GridData(120, SWT.DEFAULT);
        ignoreAllBtn = new Button(middleComp, SWT.PUSH);
        ignoreAllBtn.setText("Ignore All");
        ignoreAllBtn.setLayoutData(gd);
        ignoreAllBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                String badWord = misspelledLbl.getText();
                ignoreAll.add(badWord);
                scanForErrors();
            }
        });

        gd = new GridData(SWT.FILL, SWT.BOTTOM, true, true);
        gd.horizontalSpan = 2;
        Label personalDictionaryLbl = new Label(middleComp, SWT.NONE);
        personalDictionaryLbl.setText("Personal Dictionary:");
        personalDictionaryLbl.setLayoutData(gd);

        gd = new GridData(120, SWT.DEFAULT);
        addWordBtn = new Button(middleComp, SWT.PUSH);
        addWordBtn.setText("Add Word");
        addWordBtn.setLayoutData(gd);
        addWordBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                IDocument dummyDoc = new Document();
                addWordProposal.apply(dummyDoc);
                try {
                    userDLFile.save();
                } catch (Exception e) {
                    statusHandler.handle(Priority.PROBLEM, "Error saving user dictionary", e);
                }
                // The spell check job might have a backlog of errors
                // for this word, which no longer apply.
                // Reposition to the problem in order to clear them.
                spellCheckJob.setOffset(problem.getOffset());
                scanForErrors();
            }
        });
    }

    /**
     * Create the controls at the top of the display.
     * 
     * @param mainComp
     *            Parent composite.
     */
    private void createTopControls(Composite mainComp) {
        Composite topComp = new Composite(mainComp, SWT.NONE);
        topComp.setLayoutData(new GridData(SWT.FILL, SWT.DEFAULT, true, false));
        topComp.setLayout(new GridLayout(3, false));

        Label misspelledWordLbl = new Label(topComp, SWT.NONE);
        misspelledWordLbl.setText("Misspelled Word: ");

        GridData gd = new GridData(SWT.FILL, SWT.DEFAULT, true, false);
        misspelledLbl = new Label(topComp, SWT.NONE);
        misspelledLbl.setLayoutData(gd);

        gd = new GridData(120, SWT.DEFAULT);
        Button recheckPageBtn = new Button(topComp, SWT.PUSH);
        recheckPageBtn.setText("Recheck Page");
        recheckPageBtn.setLayoutData(gd);
        recheckPageBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                spellCheckJob.reset();
                ignoreAll.clear();
                scanForErrors();
            }

        });

        Label replaceWithLbl = new Label(topComp, SWT.NONE);
        replaceWithLbl.setText("Replace With: ");

        gd = new GridData(200, SWT.DEFAULT);
        replaceWithTF = new Text(topComp, SWT.BORDER);
        replaceWithTF.setLayoutData(gd);
        replaceWithTF.addModifyListener(new ModifyListener() {
            @Override
            public void modifyText(ModifyEvent e) {
                wordCheckLbl.setText("");
            }
        });

        gd = new GridData(120, SWT.DEFAULT);
        checkWordBtn = new Button(topComp, SWT.PUSH);
        checkWordBtn.setText("Check Word");
        checkWordBtn.setLayoutData(gd);
        // TODO instantiate a local class
        checkWordBtn.addSelectionListener(new CheckWord());

        gd = new GridData(320, SWT.DEFAULT);
        this.wordCheckLbl = new Label(topComp, SWT.NONE);
        wordCheckLbl.setLayoutData(gd);

    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * org.eclipse.ui.texteditor.spelling.ISpellingProblemCollector#endCollecting
     * ()
     */
    public void endCollecting() {
        MessageDialog.openInformation(shell, "", "Done checking document");
        styledText.setSelectionRange(0, 0);
    }

    /**
     * Initialize the controls on the display.
     */
    private void initializeComponents() {
        createMainControls();

        GridData gd = new GridData(SWT.FILL, SWT.DEFAULT, true, false);
        Label sepLbl = new Label(shell, SWT.SEPARATOR | SWT.HORIZONTAL);
        sepLbl.setLayoutData(gd);

        createCloseButton();
    }

    /**
     * Setup and open the dialog.
     * 
     * @return Return object.
     */
    public Object open() {
        // most of the code base builds Shells from Displays, but building it
        // off the calling Shell allows us to block input to the shell whose
        // text we will be checking.
        Shell parent = getParent();
        display = parent.getDisplay();
        shell = new Shell(parent, SWT.DIALOG_TRIM | SWT.PRIMARY_MODAL);
        shell.setText("Spell Check");

        // Create the main layout for the shell.
        GridLayout mainLayout = new GridLayout(1, false);
        mainLayout.marginHeight = 2;
        mainLayout.marginWidth = 2;
        mainLayout.verticalSpacing = 2;
        shell.setLayout(mainLayout);

        // Initialize all of the controls and layouts
        initializeComponents();

        setSpellCheckPreferences();
        scanForErrors();

        shell.pack();

        shell.open();
        while (!shell.isDisposed()) {
            if (!display.readAndDispatch()) {
                display.sleep();
            }
        }

        spellCheckJob.cancel();
        restoreSpellCheckPreferences();

        return returnObj;
    }

    /**
     * Restore the spell-check preferences that were in place when the dialog
     * was invoked.
     */
    private void restoreSpellCheckPreferences() {
        IPreferenceStore xstore = PreferenceConstants.getPreferenceStore();
        if (mixedWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_MIXED);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_MIXED,
                    mixedToRestore);
        }

        if (upperWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_UPPER);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_UPPER,
                    upperToRestore);
        }
        if (userDWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_USER_DICTIONARY);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_USER_DICTIONARY,
                    userDToRestore);
        }
        if (userDEncodingWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_USER_DICTIONARY_ENCODING);
        } else {
            xstore.setValue(
                    PreferenceConstants.SPELLING_USER_DICTIONARY_ENCODING,
                    userDEncodingToRestore);
        }
        if (sentenceWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_SENTENCE);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_SENTENCE,
                    sentenceToRestore);
        }
        if (digitsWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_DIGITS);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_DIGITS,
                    digitsToRestore);
        }
        if (nonLettersWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_NON_LETTERS);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_NON_LETTERS,
                    nonLettersToRestore);
        }
        if (singleLettersWasDefault) {
            xstore.setToDefault(PreferenceConstants.SPELLING_IGNORE_SINGLE_LETTERS);
        } else {
            xstore.setValue(PreferenceConstants.SPELLING_IGNORE_SINGLE_LETTERS,
                    singleLettersToRestore);
        }
    }

    /**
     * Trigger the spell check job to resume.
     */
    protected void scan() {
        spellCheckJob.schedule();
    }

    /**
     * Clear the fields that display the current error and suggestions, disable
     * all the controls that work with the current error, and call scan() to
     * resume the spell check job.
     */
    protected void scanForErrors() {
        problem = null;
        misspelledLbl.setText("");
        replaceWithTF.setText("");
        suggestionList.removeAll();
        replaceBtn.setEnabled(false);
        ignoreBtn.setEnabled(false);
        addWordBtn.setEnabled(false);
        checkWordBtn.setEnabled(false);
        wordCheckLbl.setText("");
        scan();
    }

    /**
     * Set the spell check preferences we need and save the old values so they
     * can be restored when this dialog is closed.
     */
    private void setSpellCheckPreferences() {
        IPreferenceStore xstore = PreferenceConstants.getPreferenceStore();
        mixedWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_MIXED);
        if (!mixedWasDefault) {
            mixedToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_MIXED);
        }
        upperWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_UPPER);
        if (!upperWasDefault) {
            upperToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_UPPER);
        }
        userDWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_USER_DICTIONARY);
        if (!userDWasDefault) {
            userDToRestore = xstore
                    .getString(PreferenceConstants.SPELLING_USER_DICTIONARY);
        }
        userDEncodingWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_USER_DICTIONARY_ENCODING);
        if (!userDEncodingWasDefault) {
            userDEncodingToRestore = xstore
                    .getString(PreferenceConstants.SPELLING_USER_DICTIONARY_ENCODING);
        }
        sentenceWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_SENTENCE);
        if (!sentenceWasDefault) {
            sentenceToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_SENTENCE);
        }
        digitsWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_DIGITS);
        if (!digitsWasDefault) {
            digitsToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_DIGITS);
        }
        nonLettersWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_NON_LETTERS);
        if (!nonLettersWasDefault) {
            nonLettersToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_NON_LETTERS);
        }
        singleLettersWasDefault = xstore
                .isDefault(PreferenceConstants.SPELLING_IGNORE_SINGLE_LETTERS);
        if (!singleLettersWasDefault) {
            singleLettersToRestore = xstore
                    .getBoolean(PreferenceConstants.SPELLING_IGNORE_SINGLE_LETTERS);
        }
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_MIXED, false);
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_UPPER, false);
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_SENTENCE, true);
        // In SpellCheckDlg.accept() above, we do the work of this preference,
        // since the spell checker will still return errors that contain digits.
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_DIGITS, true);
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_NON_LETTERS, true);
        xstore.setValue(PreferenceConstants.SPELLING_IGNORE_SINGLE_LETTERS,
                true);

        // Find/create the user dictionary
        // Since eclipse doesn't support more than a master and user dictionary,
        // we have a master user dictionary template which contains common words
        // not in our master dictionary.
        IPathManager pathManager = PathManagerFactory.getPathManager();
        LocalizationContext ctx = pathManager.getContext(
                LocalizationType.CAVE_STATIC, LocalizationLevel.USER);
        userDLFile = pathManager.getLocalizationFile(ctx, SPELLDICT);
        if (!userDLFile.exists()) {
            File userDFile = userDLFile.getFile();
            if (!userDFile.exists()) {
                try {
                    userDFile.createNewFile();
                    LocalizationFile defaultDLFile = pathManager
                            .getLocalizationFile(pathManager.getContext(
                                    LocalizationType.CAVE_STATIC,
                                    LocalizationLevel.BASE), SPELLDICT);
                    FileUtil.copyFile(defaultDLFile.getFile(), userDFile);
                    userDLFile.save();
                } catch (IOException e) {
                    statusHandler.handle(Priority.PROBLEM,
                            "Error creating user dictionary", e);
                } catch (LocalizationException e) {
                    statusHandler.handle(Priority.PROBLEM,
                            "Error creating user dictionary", e);
                }
            }
        }
        String pathSpec = userDLFile.getFile().getAbsolutePath();
        xstore.setValue(PreferenceConstants.SPELLING_USER_DICTIONARY, pathSpec);
        xstore.setValue(PreferenceConstants.SPELLING_USER_DICTIONARY_ENCODING,
                DICTIONARY_ENCODING);
    }
}
