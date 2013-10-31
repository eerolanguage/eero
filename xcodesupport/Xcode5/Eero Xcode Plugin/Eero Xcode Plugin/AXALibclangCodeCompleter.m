//
//  AXALibclangCodeCompleter.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/21/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "clang-c/Index.h"
#import "AXATranslationUnitWrapper.h"
#import "AXACodeCompleter_Protected.h"
#import "AXALibclangCodeCompleter.h"

//==================================================================================================
  @implementation AXALibclangCodeCompleter
//==================================================================================================
  {
  CXIndex _index;
  NSMutableDictionary* _translationUnits;
  }

  //------------------------------------------------------------------------------------------------
  - (id) init {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {
      _translationUnits = [NSMutableDictionary new];

      NSLog(@"%@: clang version: %s", [self className], clang_getCString(clang_getClangVersion()));
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (void) dealloc {
  //------------------------------------------------------------------------------------------------
    [self clearCaches];

    if (_index) {
      clang_disposeIndex(_index);
    }
  }

  //------------------------------------------------------------------------------------------------
  - (void)clearCaches {
  //------------------------------------------------------------------------------------------------
    [_translationUnits removeAllObjects];

    if ([[self superclass] instancesRespondToSelector: _cmd]) { // since it's an optional method
      [super clearCaches];
    }
  }

  //------------------------------------------------------------------------------------------------
  - (BOOL) addCodeCompleteItemsToArray: (NSMutableArray*) items
                   usingSourceCodeText: (NSString*) text
                                  line: (NSUInteger) line
                                column: (NSUInteger) column
                       compilerOptions: (NSArray*) options {
  //------------------------------------------------------------------------------------------------
    const NSUInteger initialItemsCount = items.count;

    // The clang index can be reused
    if (_index == NULL) {
      _index = clang_createIndex(0, 0);
    }

    if (_index && options.count > 0) { // Note: options[0] is always the input filename
      NSString* filenameString = options[0];

      // Convert options to clang compiler arguments
      const int numOfArgs = (int)(options.count);
      const char* args[numOfArgs];
      for (NSUInteger i = 0; i < numOfArgs; i++) {
        args[i] = [options[i] UTF8String];
      }
      const char* const filename = args[0];

      const unsigned numOfUnsavedFiles = 1;
      struct CXUnsavedFile unsavedFile = {
          .Filename = filename,
          .Contents = [text UTF8String],
          .Length   = [text length]
      };

      CXTranslationUnit translationUnit;
      AXATranslationUnitWrapper* translationUnitWrapper = _translationUnits[filenameString];
      if (translationUnitWrapper == nil) {
        translationUnit = clang_parseTranslationUnit(_index,
                                                      NULL,
                                                      args, numOfArgs,
                                                      &unsavedFile, numOfUnsavedFiles,
                                                      CXTranslationUnit_Incomplete |
                                                      CXTranslationUnit_CacheCompletionResults);
        if (translationUnit) {
          _translationUnits[filenameString] =
              [[AXATranslationUnitWrapper alloc] initWithTranslationUnit: translationUnit];
        }
      } else {
        translationUnit = [translationUnitWrapper translationUnit];
      }

      CXCodeCompleteResults* results =
          clang_codeCompleteAt(translationUnit,
                               filename,
                               (unsigned)line + 1, (unsigned)column + 1,
                               &unsavedFile, numOfUnsavedFiles,
                               CXCodeComplete_IncludeMacros | CXCodeComplete_IncludeCodePatterns);
      if (results) {
        [self processAnyErrorsForResults: results];
        clang_sortCodeCompletionResults(results->Results, results->NumResults);
        [self addCompletionResults: results toItems: items currentColumn: column];
        clang_disposeCodeCompleteResults(results);
      }
    }

    return items.count > initialItemsCount;
  }

  //------------------------------------------------------------------------------------------------
  - (void) processAnyErrorsForResults: (CXCodeCompleteResults*) results {
  //------------------------------------------------------------------------------------------------
    for (unsigned i = 0; i < clang_codeCompleteGetNumDiagnostics(results); i++) {
      CXDiagnostic diag = clang_codeCompleteGetDiagnostic(results, i);
      CXString spelling = clang_getDiagnosticSpelling(diag);
      NSLog(@"************ ERROR: %s ************", clang_getCString(spelling));
      clang_disposeString(spelling);
      clang_disposeDiagnostic(diag);
    }
  }

  //------------------------------------------------------------------------------------------------
  - (void) addCompletionResults: (CXCodeCompleteResults*) results
                        toItems: (NSMutableArray*) items
                  currentColumn: (NSUInteger) currentColumn {
  //------------------------------------------------------------------------------------------------
    for (unsigned i = 0; i < results->NumResults; i++) {

      CXCompletionString completion = results->Results[i].CompletionString;
      const enum CXCursorKind cursorKind = results->Results[i].CursorKind;

      NSMutableString* displayText    = [NSMutableString new];
      NSMutableString* insertionText  = [NSMutableString new];
      NSString*        resultTypeText = nil;

      const int resultPriority = clang_getCompletionPriority(completion);
      const BOOL resultDisabled = (clang_getCompletionAvailability(completion) !=
                                   CXAvailability_Available);
      BOOL started = NO;

      for (unsigned j = 0; j < clang_getNumCompletionChunks(completion); j++) {
        const CXString chunkText = clang_getCompletionChunkText(completion, j);
        const enum CXCompletionChunkKind kind = clang_getCompletionChunkKind(completion, j);
        const char *spelling = clang_getCString(chunkText);
        if (!spelling) {
          spelling = "";
        }
        if (kind == CXCompletionChunk_TypedText) {
          started = YES;
        } else if (kind == CXCompletionChunk_ResultType) {
          resultTypeText = @(spelling);
        }
        if (started && kind != CXCompletionChunk_Informative) {
          if (kind == CXCompletionChunk_Placeholder) {
            [insertionText appendString: [NSString stringWithFormat: self.placeholderFormatter,
                                                                     spelling]];
          } else {
            [insertionText appendString: @(spelling)];
            if (kind == CXCompletionChunk_VerticalSpace) { // TODO: pass in indent level in init
              [insertionText appendFormat: @"%*c", (int)currentColumn, ' '];
            }
          }
          [displayText appendString: @(spelling)];
        }
        clang_disposeString(chunkText);
      }
      NSString* kindName = [self nameForCursorKind: cursorKind];

      id item = [self createItemOfType: kindName
                           displayText: displayText
                         insertionText: insertionText
                            resultType: resultTypeText
                              priority: resultPriority
                              disabled: resultDisabled];
      [items addObject: item];
    }
  }

  //------------------------------------------------------------------------------------------------
  - (NSString*) nameForCursorKind: (const enum CXCursorKind) kind {
  //------------------------------------------------------------------------------------------------
    NSString* name = nil;
    switch (kind) {
        case CXCursor_UnexposedDecl:
          break;
        case CXCursor_StructDecl:
          name = @"Struct";
          break;
        case CXCursor_UnionDecl:
          name = @"Union";
          break;
        case CXCursor_ClassDecl:
          name = @"Class";
          break;
        case CXCursor_EnumDecl:
          name = @"Enum";
          break;
        case CXCursor_FieldDecl:
          name = @"Field";
          break;
        case CXCursor_EnumConstantDecl:
          name = @"EnumConstant";
          break;
        case CXCursor_FunctionDecl:
          name = @"Function";
          break;
        case CXCursor_VarDecl:
          name = @"GlobalVariable";
          break;
        case CXCursor_ParmDecl:
          break;
        case CXCursor_ObjCInterfaceDecl:
          name = @"Class";
          break;
        case CXCursor_ObjCCategoryDecl:
          name = @"Category";
          break;
        case CXCursor_ObjCProtocolDecl:
          name = @"Protocol";
          break;
        case CXCursor_ObjCPropertyDecl:
          name = @"Property";
          break;
        case CXCursor_ObjCIvarDecl:
          name = @"InstanceVariable";
          break;
        case CXCursor_ObjCInstanceMethodDecl:
          name = @"InstanceMethod";
          break;
        case CXCursor_ObjCClassMethodDecl:
          name = @"ClassMethod";
          break;
        case CXCursor_ObjCImplementationDecl:
          break;
        case CXCursor_ObjCCategoryImplDecl:
          break;
        case CXCursor_TypedefDecl:
          name = @"Typedef";
          break;
        case CXCursor_CXXMethod:
          name = @"Function";
          break;
        case CXCursor_Namespace:
          name = @"Namespace";
          break;
        case CXCursor_LinkageSpec:
          break;
        case CXCursor_Constructor:
          break;
        case CXCursor_Destructor:
          break;
        case CXCursor_ConversionFunction:
          break;
        case CXCursor_TemplateTypeParameter:
          break;
        case CXCursor_NonTypeTemplateParameter:
          break;
        case CXCursor_TemplateTemplateParameter:
          break;
        case CXCursor_FunctionTemplate:
          break;
        case CXCursor_ClassTemplate:
          name = @"ClassTemplate";
          break;
        case CXCursor_ClassTemplatePartialSpecialization:
          break;
        case CXCursor_NamespaceAlias:
          break;
        case CXCursor_UsingDirective:
          break;
        case CXCursor_UsingDeclaration:
          break;
        case CXCursor_TypeAliasDecl:
          break;
        case CXCursor_ObjCSynthesizeDecl:
          break;
        case CXCursor_ObjCDynamicDecl:
          break;
        case CXCursor_CXXAccessSpecifier:
          break;
        case CXCursor_FirstRef:
          break;
        case CXCursor_ObjCProtocolRef:
          name = @"Protocol";
          break;
        case CXCursor_ObjCClassRef:
          name = @"Class";
          break;
        case CXCursor_TypeRef:
          name = @"BuiltinType";
          break;
        case CXCursor_CXXBaseSpecifier:
          break;
        case CXCursor_TemplateRef:
          break;
        case CXCursor_NamespaceRef:
          break;
        case CXCursor_MemberRef:
          name = @"Member";
          break;
        case CXCursor_LabelRef:
          break;
        case CXCursor_OverloadedDeclRef:
          break;
        case CXCursor_VariableRef:
          name = @"LocalVariable";
          break;
        case CXCursor_FirstInvalid:
          break;
        case CXCursor_NoDeclFound:
          break;
        case CXCursor_NotImplemented:
          break;
        case CXCursor_InvalidCode:
          break;
        case CXCursor_FirstExpr:
          break;
        case CXCursor_DeclRefExpr:
          break;
        case CXCursor_MemberRefExpr:
          name = @"Member";
          break;
        case CXCursor_CallExpr:
          break;
        case CXCursor_ObjCMessageExpr:
          break;
        case CXCursor_BlockExpr:
          name = @"Function";
          break;
        case CXCursor_IntegerLiteral:
          break;
        case CXCursor_FloatingLiteral:
          break;
        case CXCursor_ImaginaryLiteral:
          break;
        case CXCursor_StringLiteral:
          break;
        case CXCursor_CharacterLiteral:
          break;
        case CXCursor_ParenExpr:
          break;
        case CXCursor_UnaryOperator:
          break;
        case CXCursor_ArraySubscriptExpr:
          break;
        case CXCursor_BinaryOperator:
          break;
        case CXCursor_CompoundAssignOperator:
          break;
        case CXCursor_ConditionalOperator:
          break;
        case CXCursor_CStyleCastExpr:
          break;
        case CXCursor_CompoundLiteralExpr:
          break;
        case CXCursor_InitListExpr:
          break;
        case CXCursor_AddrLabelExpr:
          break;
        case CXCursor_StmtExpr:
          break;
        case CXCursor_GenericSelectionExpr:
          break;
        case CXCursor_GNUNullExpr:
          break;
        case CXCursor_CXXStaticCastExpr:
          break;
        case CXCursor_CXXDynamicCastExpr:
          break;
        case CXCursor_CXXReinterpretCastExpr:
          break;
        case CXCursor_CXXConstCastExpr:
          break;
        case CXCursor_CXXFunctionalCastExpr:
          break;
        case CXCursor_CXXTypeidExpr:
          break;
        case CXCursor_CXXBoolLiteralExpr:
          break;
        case CXCursor_CXXNullPtrLiteralExpr:
          break;
        case CXCursor_CXXThisExpr:
          break;
        case CXCursor_CXXThrowExpr:
          break;
        case CXCursor_CXXNewExpr:
          break;
        case CXCursor_CXXDeleteExpr:
          break;
        case CXCursor_UnaryExpr:
          break;
        case CXCursor_ObjCStringLiteral:
          break;
        case CXCursor_ObjCEncodeExpr:
          break;
        case CXCursor_ObjCSelectorExpr:
          break;
        case CXCursor_ObjCProtocolExpr:
          name = @"Protocol";
          break;
        case CXCursor_ObjCBridgedCastExpr:
          break;
        case CXCursor_PackExpansionExpr:
          break;
        case CXCursor_SizeOfPackExpr:
          break;
        case CXCursor_LambdaExpr:
          break;
        case CXCursor_ObjCBoolLiteralExpr:
          break;
        case CXCursor_ObjCSelfExpr:
          break;
        case CXCursor_FirstStmt:
          break;
        case CXCursor_LabelStmt:
          break;
        case CXCursor_CompoundStmt:
          break;
        case CXCursor_CaseStmt:
          break;
        case CXCursor_DefaultStmt:
          break;
        case CXCursor_IfStmt:
          break;
        case CXCursor_SwitchStmt:
          break;
        case CXCursor_WhileStmt:
          break;
        case CXCursor_DoStmt:
          break;
        case CXCursor_ForStmt:
          break;
        case CXCursor_GotoStmt:
          break;
        case CXCursor_IndirectGotoStmt:
          break;
        case CXCursor_ContinueStmt:
          break;
        case CXCursor_BreakStmt:
          break;
        case CXCursor_ReturnStmt:
          break;
        case CXCursor_GCCAsmStmt:
          break;
        case CXCursor_ObjCAtTryStmt:
          break;
        case CXCursor_ObjCAtCatchStmt:
          break;
        case CXCursor_ObjCAtFinallyStmt:
          break;
        case CXCursor_ObjCAtThrowStmt:
          break;
        case CXCursor_ObjCAtSynchronizedStmt:
          break;
        case CXCursor_ObjCAutoreleasePoolStmt:
          break;
        case CXCursor_ObjCForCollectionStmt:
          break;
        case CXCursor_CXXCatchStmt:
          break;
        case CXCursor_CXXTryStmt:
          break;
        case CXCursor_CXXForRangeStmt:
          break;
        case CXCursor_SEHTryStmt:
          break;
        case CXCursor_SEHExceptStmt:
          break;
        case CXCursor_SEHFinallyStmt:
          break;
        case CXCursor_MSAsmStmt:
          break;
        case CXCursor_NullStmt:
          break;
        case CXCursor_DeclStmt:
          break;
        case CXCursor_OMPParallelDirective:
          break;
        case CXCursor_TranslationUnit:
          break;
        case CXCursor_FirstAttr:
          break;
        case CXCursor_IBActionAttr:
          name = @"IBActionMethod";
          break;
        case CXCursor_IBOutletAttr:
          name = @"IBOutlet";
          break;
        case CXCursor_IBOutletCollectionAttr:
          name = @"IBOutletCollection";
          break;
        case CXCursor_CXXFinalAttr:
          break;
        case CXCursor_CXXOverrideAttr:
          break;
        case CXCursor_AnnotateAttr:
          break;
        case CXCursor_AsmLabelAttr:
          break;
        case CXCursor_PackedAttr:
          break;
        case CXCursor_PreprocessingDirective:
          break;
        case CXCursor_MacroDefinition:
          name = @"Macro";
          break;
        case CXCursor_MacroExpansion:
          name = @"Macro";
          break;
        case CXCursor_InclusionDirective:
          break;
        case CXCursor_ModuleImportDecl:
          break;
    }
    return name;
  }

@end











